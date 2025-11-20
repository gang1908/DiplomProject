//
//  AdService.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage
internal import Combine
import FirebaseAuth

//class AdService: AdServiceProtocol, ObservableObject {
//    @Published private(set) var allAds: [Advertisement] = []
//    @Published private(set) var isLoading = false
//    @Published private(set) var error: String?
//    
//    var allAdsPublisher: Published<[Advertisement]>.Publisher { $allAds }
//    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
//    var errorPublisher: Published<String?>.Publisher { $error }
//    
//    private let db = Firestore.firestore()
//    private let storage = Storage.storage()
//    private var listener: ListenerRegistration?
//    
//    func loadAds() async {
//        await MainActor.run {
//            isLoading = true
//            error = nil
//        }
//        
//        do {
//            let snapshot = try await db.collection("ads")
//                .order(by: "createdAt", descending: true)
//                .getDocuments()
//            
//            let ads = snapshot.documents.compactMap { document -> Advertisement? in
//                do {
//                    let ad = try document.data(as: Advertisement.self)
//                    return ad
//                } catch {
//                    return nil
//                }
//            }
//            
//            await MainActor.run {
//                self.allAds = ads
//                self.isLoading = false
//                self.error = nil
//            }
//        } catch {
//            await MainActor.run {
//                self.isLoading = false
//            }
//        }
//    }
//    
//    // Загрузка в реальном времени
//    func listenToAllAds() {
//        isLoading = true
//        error = nil
//        
//        listener = db.collection("ads")
//            .order(by: "createdAt", descending: true)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//                
//                if let error = error {
//                    self.isLoading = false
//                    self.error = "Ошибка загрузки: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    self.allAds = []
//                    self.isLoading = false
//                    return
//                }
//                
//                let ads = documents.compactMap { document -> Advertisement? in
//                    do {
//                        let ad = try document.data(as: Advertisement.self)
//                        return ad
//                    } catch {
//                        return nil
//                    }
//                }
//                
//                self.allAds = ads
//                self.isLoading = false
//                self.error = nil
//            }
//    }
//    
//    func createAd(_ ad: Advertisement, images: [UIImage]) async throws -> String {
//        let adRef = db.collection("ads").document()
//        var newAd = ad
//        newAd.id = adRef.documentID
//        
//        
//        // Загружаем изображения если есть
//        if !images.isEmpty {
//            newAd.imageUrls = try await uploadImages(images, adId: newAd.id!)
//        } else {
//        }
//        
//        // Сохраняем в Firestore
//        do {
//            try adRef.setData(from: newAd)
//            return newAd.id!
//        } catch {
//            throw error
//        }
//    }
//    private func uploadImages(_ images: [UIImage], adId: String) async throws -> [String] {
//        var urls: [String] = []
//        
//        for (index, image) in images.enumerated() {
//            guard let data = image.jpegData(compressionQuality: 0.7) else { continue }
//            
//            let ref = storage.reference().child("ads/\(adId)/image_\(index).jpg")
//            _ = try await ref.putDataAsync(data)
//            let url = try await ref.downloadURL()
//            urls.append(url.absoluteString)
//        }
//        
//        return urls
//    }
//    
//    func getAd(by id: String) async -> Advertisement? {
//        do {
//            let document = try await db.collection("ads").document(id).getDocument()
//            if let ad = try? document.data(as: Advertisement.self) {
//                return ad
//            } else {
//                return nil
//            }
//        } catch {
//            return nil
//        }
//    }
//    
//    func stopListening() {
//        listener?.remove()
//        listener = nil
//    }
//    
//    deinit {
//        stopListening()
//    }
//}
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
    
    // Создание объявления с улучшенной отладкой
    func createAd(_ ad: Advertisement, images: [UIImage]) async throws -> String {
            print("🟡 === НАЧИНАЕМ СОЗДАНИЕ ОБЪЯВЛЕНИЯ ===")
            
            // Проверяем авторизацию
            guard let currentUser = Auth.auth().currentUser else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            print("🟢 Пользователь авторизован: \(currentUser.uid)")
            
            // Получаем токен для проверки
            do {
                let token = try await currentUser.getIDToken()
            } catch {
            }
            
            let adRef = db.collection("ads").document()
            var newAd = ad
            newAd.id = adRef.documentID
            
            // Сохраняем в Firestore
            do {
                try adRef.setData(from: newAd)
                
                // Проверяем, что документ создан
                try await Task.sleep(nanoseconds: 1_000_000_000) // Ждем 1 секунду
                let document = try await adRef.getDocument()
                
                return newAd.id!
            } catch {
                throw error
            }
        }
    
    
    private func uploadImages(_ images: [UIImage], adId: String) async throws -> [String] {
        var urls: [String] = []
        
        for (index, image) in images.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.7) else {
                continue
            }
            
            let ref = storage.reference().child("ads/\(adId)/image_\(index).jpg")
            
            do {
                _ = try await ref.putDataAsync(data)
                let url = try await ref.downloadURL()
                urls.append(url.absoluteString)
            } catch {
                throw error
            }
        }
        
        return urls
    }
    
    // Загрузка объявлений с отладкой
    func loadAds() async {
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let snapshot = try await db.collection("ads")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let ads = snapshot.documents.compactMap { document -> Advertisement? in
                do {
                    let ad = try document.data(as: Advertisement.self)
                    return ad
                } catch {
                    return nil
                }
            }
            
            await MainActor.run {
                self.allAds = ads
                self.isLoading = false
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.error = "Ошибка загрузки: \(error.localizedDescription)"
            }
        }
    }
    
    // Слушатель в реальном времени с отладкой
    func listenToAllAds() {
        isLoading = true
        error = nil
        
        // Останавливаем предыдущий слушатель
        listener?.remove()
        
        listener = db.collection("ads")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.error = "Ошибка загрузки: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.allAds = []
                    self.isLoading = false
                    print("ℹ️ Слушатель: Нет документов")
                    return
                }
                
                let ads = documents.compactMap { document -> Advertisement? in
                    do {
                        let ad = try document.data(as: Advertisement.self)
                        return ad
                    } catch {
                        return nil
                    }
                }
                
                self.allAds = ads
                self.isLoading = false
                self.error = nil
            }
    }
    
    func getAd(by id: String) async -> Advertisement? {
        do {
            let document = try await db.collection("ads").document(id).getDocument()
            if let ad = try? document.data(as: Advertisement.self) {
                return ad
            } else {
                return nil
            }
        } catch {
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
