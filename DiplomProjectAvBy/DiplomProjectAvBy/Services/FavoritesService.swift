//
//  FavoritesService.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 2.11.25.
//

// Services/FavoritesService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
internal import Combine

class FavoritesService: FavoritesServiceProtocol, ObservableObject {
    @Published private(set) var favoriteAds: [FavoriteAd] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    var favoriteAdsPublisher: Published<[FavoriteAd]>.Publisher { $favoriteAds }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    
    private let db = Firestore.firestore()
    private let adService: AdServiceProtocol
    private var listener: ListenerRegistration?
    
    init(adService: AdServiceProtocol = AdService()) {
        self.adService = adService
    }
    
    func listenToFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Необходимо авторизоваться"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        
        // Останавливаем предыдущий слушатель
        listener?.remove()
        
        listener = db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Ошибка загрузки избранного: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.favoriteAds = []
                    return
                }
                
                let favorites = documents.compactMap { document -> FavoriteAd? in
                    do {
                        var favorite = try document.data(as: FavoriteAd.self)
                        favorite.id = document.documentID
                        return favorite
                    } catch {
                        return nil
                    }
                }
                
                // Сортируем локально по дате добавления
                let sortedFavorites = favorites.sorted { $0.addedAt > $1.addedAt }
                
                self.favoriteAds = sortedFavorites
                self.errorMessage = nil
                
                self.loadAdsDetails(for: sortedFavorites)
            }
    }
    
    private func loadAdsDetails(for favorites: [FavoriteAd]) {
        Task {
            var updatedFavorites: [FavoriteAd] = []
            
            for favorite in favorites {
                if let ad = await adService.getAd(by: favorite.adId) {
                    var updatedFavorite = favorite
                    updatedFavorite.advertisement = ad
                    updatedFavorites.append(updatedFavorite)
                } else {
                    updatedFavorites.append(favorite)
                }
            }
            
            await MainActor.run {
                self.favoriteAds = updatedFavorites
            }
        }
    }
    
    func addToFavorites(ad: Advertisement) async -> Bool {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            let error = "Ошибка: Пользователь не авторизован"
            await MainActor.run {
                errorMessage = error
            }
            return false
        }
        
        guard let adId = ad.id else {
            let error = "Ошибка: У объявления нет ID"
            await MainActor.run {
                errorMessage = error
            }
            return false
        }
        
        
        if isFavorite(adId: adId) {
            let error = " Объявление уже в избранном"
            await MainActor.run {
                errorMessage = error
            }
            return false
        }
        
        let favorite = FavoriteAd(
            adId: adId,
            userId: userId,
            addedAt: Date()
        )
        
        
        do {
            let documentRef = try await db.collection("favorites").addDocument(from: favorite)
            await MainActor.run {
                errorMessage = nil
            }
            return true
        } catch {
            let errorMsg = " Ошибка Firestore: \(error.localizedDescription)"
            await MainActor.run {
                errorMessage = errorMsg
            }
            return false
        }
    }
    
    func removeFromFavorites(adId: String) async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                errorMessage = "Необходимо авторизоваться"
            }
            return false
        }
        
        
        do {
            let query = db.collection("favorites")
                .whereField("adId", isEqualTo: adId)
                .whereField("userId", isEqualTo: userId)
            
            let snapshot = try await query.getDocuments()
            
            
            for document in snapshot.documents {
                try await document.reference.delete()
            }
            
            await MainActor.run {
                errorMessage = nil
            }
            return true
        } catch {
            let errorMsg = "Ошибка удаления из избранного: \(error.localizedDescription)"
            await MainActor.run {
                errorMessage = errorMsg
            }
            return false
        }
    }
    
    func toggleFavorite(ad: Advertisement) async -> Bool {
        guard let adId = ad.id else {
            await MainActor.run {
                errorMessage = " Ошибка: У объявления нет ID"
            }
            return false
        }
        
        if isFavorite(adId: adId) {
            return await removeFromFavorites(adId: adId)
        } else {
            return await addToFavorites(ad: ad)
        }
    }
    
    func clearAllFavorites() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                errorMessage = "Необходимо авторизоваться"
            }
            return false
        }
        
        do {
            let query = db.collection("favorites")
                .whereField("userId", isEqualTo: userId)
            
            let snapshot = try await query.getDocuments()
            
            for document in snapshot.documents {
                try await document.reference.delete()
            }
            
            await MainActor.run {
                errorMessage = nil
            }
            return true
        } catch {
            let errorMsg = "Ошибка очистки избранного: \(error.localizedDescription)"
            await MainActor.run {
                errorMessage = errorMsg
            }
            return false
        }
    }
    
    func isFavorite(adId: String) -> Bool {
        return favoriteAds.contains { $0.adId == adId }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}
