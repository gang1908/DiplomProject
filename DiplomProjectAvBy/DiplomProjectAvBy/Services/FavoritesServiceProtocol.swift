//
//  Protocol.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 2.11.25.
//

internal import Combine

protocol FavoritesServiceProtocol {
    var favoriteAds: [FavoriteAd] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    var favoriteAdsPublisher: Published<[FavoriteAd]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    
    func listenToFavorites()
    func stopListening()
    func addToFavorites(ad: Advertisement) async -> Bool
    func removeFromFavorites(adId: String) async -> Bool
    func toggleFavorite(ad: Advertisement) async -> Bool
    func clearAllFavorites() async -> Bool
    func isFavorite(adId: String) -> Bool
}
