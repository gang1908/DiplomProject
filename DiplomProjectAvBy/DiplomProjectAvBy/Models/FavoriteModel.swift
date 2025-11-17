//
//  FavoriteModel.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 2.11.25.
//

import Foundation
import FirebaseFirestore

struct FavoriteAd: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let adId: String
    let userId: String
    let addedAt: Date
    var advertisement: Advertisement?
    
    enum CodingKeys: String, CodingKey {
        case id
        case adId
        case userId
        case addedAt
    }
    
    init(id: String? = nil, adId: String, userId: String, addedAt: Date = Date(), advertisement: Advertisement? = nil) {
        self.id = id
        self.adId = adId
        self.userId = userId
        self.addedAt = addedAt
        self.advertisement = advertisement
    }
}
