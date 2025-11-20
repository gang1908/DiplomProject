//
//  AddModel.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

// Models/Advertisement.swift
import Foundation
import FirebaseFirestore

struct Advertisement: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let price: Double
    var category: String
    let city: String
    let createdAt: Date
    var imageUrls: [String]
    let userId: String
    var userEmail: String
    let userName: String
    let condition: String
    let brand: String?
    let model: String?
    let year: Int?
    let mileage: Int?
    let engineVolume: Double?
    let fuelType: String?
    let transmission: String?
    
    
    // Инициализатор для создания нового объявления
    init(
        id: String? = nil,
        title: String,
        description: String,
        price: Double,
        category: String,
        city: String,
        createdAt: Date = Date(),
        imageUrls: [String] = [],
        userId: String,
        userEmail: String,
        userName: String,
        condition: String = "б/у",
        brand: String? = nil,
        model: String? = nil,
        year: Int? = nil,
        mileage: Int? = nil,
        engineVolume: Double? = nil,
        fuelType: String? = nil,
        transmission: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.category = category
        self.city = city
        self.createdAt = createdAt
        self.imageUrls = imageUrls
        self.userId = userId
        self.userEmail = userEmail
        self.userName = userName
        self.condition = condition
        self.brand = brand
        self.model = model
        self.year = year
        self.mileage = mileage
        self.engineVolume = engineVolume
        self.fuelType = fuelType
        self.transmission = transmission
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let number = NSNumber(value: price)
        return "\(formatter.string(from: number) ?? "\(price)") руб."
    }
    
    var shortDescription: String {
        return String(description.prefix(100)) + (description.count > 100 ? "..." : "")
    }

}

import UIKit

struct CreateAdForm {
    var title: String = ""
    var description: String = ""
    var price: String = ""
    var category: Category = .allCathegories
    var city: String = ""
    var selectedImages: [UIImage] = []
    
    // Валидация формы
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !price.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(price) != nil &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// Перечисление категорий
enum Category: String, CaseIterable {
    case allCathegories = "Все категории"
    case carsWithMileage = "Автомобили с пробегом"
    case spareParts = "Б/у запчасти для авто"
    case newCars = "Новые автомобили"
    case specialEquipment = "Спецтехника"
    case tiresAndDiscs = "Шины и диски"
    case cargoTransport = "Грузовой транспорт"
    case electronics = "Электромобили"

    static var all: [String] {
            return Category.allCases.map { $0.rawValue }
        }
}

extension CreateAdForm {
    func toAdvertisement(userId: String, userEmail: String, userName: String) -> Advertisement? {
        guard let priceValue = Double(price) else { return nil }
        
        return Advertisement(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            price: priceValue,
            category: category.rawValue,
            city: city.trimmingCharacters(in: .whitespaces),
            userId: userId,
            userEmail: userEmail,
            userName: userName
        )
    }
}
