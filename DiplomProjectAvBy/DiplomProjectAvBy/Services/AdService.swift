//
//  AdService.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

import FirebaseFirestore
import FirebaseStorage
internal import Combine

class AdService: AdServiceProtocol, ObservableObject {
    @Published private(set) var allAds: [Advertisement] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    var allAdsPublisher: Published<[Advertisement]>.Publisher { $allAds }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<String?>.Publisher { $error }
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    
    func loadAds() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        print("🟡 AdService: Начало загрузки объявлений")
        
        do {
            let snapshot = try await db.collection("ads")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let ads = snapshot.documents.compactMap { document -> Advertisement? in
                do {
                    let ad = try document.data(as: Advertisement.self)
                    print("✅ AdService: Загружено объявление - \(ad.title) (ID: \(ad.id ?? "no id"))")
                    return ad
                } catch {
                    print("❌ AdService: Ошибка парсинга документа \(document.documentID): \(error)")
                    return nil
                }
            }
            
            await MainActor.run {
                self.allAds = ads
                self.isLoading = false
                self.error = nil
                print("✅ AdService: Успешно загружено \(ads.count) объявлений")
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.error = "Ошибка загрузки: \(error.localizedDescription)"
                print("❌ AdService: Ошибка загрузки: \(error)")
            }
        }
    }
    
    // Загрузка в реальном времени
    func listenToAllAds() {
        isLoading = true
        error = nil
        
        print("🟡 AdService: Запуск слушателя в реальном времени")
        
        listener = db.collection("ads")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.error = "Ошибка загрузки: \(error.localizedDescription)"
                    print("❌ AdService: Ошибка слушателя: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.allAds = []
                    self.isLoading = false
                    print("ℹ️ AdService: Нет документов в слушателе")
                    return
                }
                
                let ads = documents.compactMap { document -> Advertisement? in
                    do {
                        let ad = try document.data(as: Advertisement.self)
                        return ad
                    } catch {
                        print("❌ AdService: Ошибка парсинга в слушателе: \(error)")
                        return nil
                    }
                }
                
                self.allAds = ads
                self.isLoading = false
                self.error = nil
                print("✅ AdService: Слушатель обновил \(ads.count) объявлений")
            }
    }
    
    // Создание объявления с улучшенной отладкой
    func createAd(_ ad: Advertisement, images: [UIImage]) async throws -> String {
        print("🟡 AdService: Создание нового объявления")
        
        let adRef = db.collection("ads").document()
        var newAd = ad
        newAd.id = adRef.documentID
        
        print("✅ AdService: Создан ID объявления: \(newAd.id!)")
        
        // Загружаем изображения если есть
        if !images.isEmpty {
            print("🟡 AdService: Загрузка \(images.count) изображений")
            newAd.imageUrls = try await uploadImages(images, adId: newAd.id!)
        } else {
            print("ℹ️ AdService: Нет изображений для загрузки")
        }
        
        // Сохраняем в Firestore
        do {
            try adRef.setData(from: newAd)
            print("✅ AdService: Объявление успешно сохранено в Firestore")
            print("📋 Данные объявления:")
            print("   - ID: \(newAd.id!)")
            print("   - Заголовок: \(newAd.title)")
            print("   - Цена: \(newAd.price)")
            print("   - Категория: \(newAd.category)")
            print("   - Город: \(newAd.city)")
            print("   - Пользователь: \(newAd.userId)")
            print("   - Изображений: \(newAd.imageUrls.count)")
            
            return newAd.id!
        } catch {
            print("❌ AdService: Ошибка сохранения в Firestore: \(error)")
            throw error
        }
    }
    
    // Остальные методы без изменений...
    private func uploadImages(_ images: [UIImage], adId: String) async throws -> [String] {
        var urls: [String] = []
        
        for (index, image) in images.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.7) else { continue }
            
            let ref = storage.reference().child("ads/\(adId)/image_\(index).jpg")
            _ = try await ref.putDataAsync(data)
            let url = try await ref.downloadURL()
            urls.append(url.absoluteString)
            print("✅ AdService: Загружено изображение \(index + 1)/\(images.count)")
        }
        
        return urls
    }
    
    func getAd(by id: String) async -> Advertisement? {
        do {
            let document = try await db.collection("ads").document(id).getDocument()
            if let ad = try? document.data(as: Advertisement.self) {
                print("✅ AdService: Найдено объявление по ID \(id)")
                return ad
            } else {
                print("❌ AdService: Объявление с ID \(id) не найдено")
                return nil
            }
        } catch {
            print("❌ AdService: Ошибка получения объявления \(id): \(error)")
            return nil
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
        print("🟡 AdService: Слушатель остановлен")
    }
    
    deinit {
        stopListening()
    }
}
