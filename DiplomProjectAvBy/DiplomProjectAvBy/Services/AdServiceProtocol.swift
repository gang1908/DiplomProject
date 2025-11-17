//
//  AdServiceProtocol.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 2.11.25.
//

internal import Combine
import UIKit

protocol AdServiceProtocol {
    var allAds: [Advertisement] { get }
    var isLoading: Bool { get }
    var error: String? { get }
    
    var allAdsPublisher: Published<[Advertisement]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<String?>.Publisher { get }
    
    func getAd(by id: String) async -> Advertisement?
    func loadAds() async
    func listenToAllAds()
    func stopListening()
    func createAd(_ ad: Advertisement, images: [UIImage]) async throws -> String
}
