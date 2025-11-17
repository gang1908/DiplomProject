//
//  FavoritesViewMidel.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 2.11.25.
//

// ViewModels/FavoritesViewModel.swift
// ViewModels/FavoritesViewModel.swift
import Foundation
internal import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteAds: [FavoriteAd] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesService: FavoritesServiceProtocol = FavoritesService()) {
        self.favoritesService = favoritesService
        setupBindings()
    }
    
    private func setupBindings() {
        favoritesService.favoriteAdsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoriteAds)
        
        favoritesService.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        favoritesService.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error
                self?.showErrorAlert = error != nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Intent Methods
    
    func loadFavorites() {
        favoritesService.listenToFavorites()
    }
    
    func stopListening() {
        favoritesService.stopListening()
    }
    
    func addToFavorites(ad: Advertisement) async -> Bool {
        return await favoritesService.addToFavorites(ad: ad)
    }
    
    func removeFromFavorites(adId: String) async -> Bool {
        return await favoritesService.removeFromFavorites(adId: adId)
    }
    
    func toggleFavorite(ad: Advertisement) async -> Bool {
        return await favoritesService.toggleFavorite(ad: ad)
    }
    
    func clearAllFavorites() async -> Bool {
        return await favoritesService.clearAllFavorites()
    }
    
    func isFavorite(adId: String) -> Bool {
        favoritesService.isFavorite(adId: adId)
    }
}
