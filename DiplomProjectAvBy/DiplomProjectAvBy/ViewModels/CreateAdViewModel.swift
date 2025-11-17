//
//  CreateAdViewModel.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

import SwiftUI
import FirebaseAuth
internal import Combine

class CreateAdViewModel: ObservableObject {
    @Published var form = CreateAdForm()
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    
    private let adService: AdServiceProtocol
    
    init(adService: AdServiceProtocol = AdService()) {
        self.adService = adService
    }
    
    var canSubmit: Bool {
        form.isValid && !isLoading
    }
    
    func createAd() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Нужно войти в аккаунт"
            print("❌ CreateAd: Пользователь не авторизован")
            return
        }
        
        guard let price = Double(form.price) else {
            errorMessage = "Введите корректную цену"
            print("❌ CreateAd: Некорректная цена: \(form.price)")
            return
        }
        
        print("🟡 CreateAd: Начало создания объявления")
        print("📋 Данные формы:")
        print("   - Заголовок: \(form.title)")
        print("   - Описание: \(form.description)")
        print("   - Цена: \(price)")
        print("   - Категория: \(form.category.rawValue)")
        print("   - Город: \(form.city)")
        print("   - Пользователь: \(user.uid)")
        
        let ad = Advertisement(
            title: form.title,
            description: form.description,
            price: price,
            category: form.category.rawValue,
            city: form.city,
            userId: user.uid,
            userEmail: user.email ?? "",
            userName: user.displayName ?? user.email?.components(separatedBy: "@").first ?? "Пользователь"
        )
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let adId = try await adService.createAd(ad, images: form.selectedImages)
                
                await MainActor.run {
                    self.isLoading = false
                    self.showSuccess = true
                    self.resetForm()
                    print("✅ CreateAd: Объявление успешно создано с ID: \(adId)")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
                    print("❌ CreateAd: Ошибка создания объявления: \(error)")
                }
            }
        }
    }
    
    // Остальные методы без изменений...
    func resetForm() {
        form = CreateAdForm()
    }
    
    func addImages(_ newImages: [UIImage]) {
        let availableSlots = 3 - form.selectedImages.count
        guard availableSlots > 0 else { return }
        form.selectedImages.append(contentsOf: newImages.prefix(availableSlots))
    }
    
    func removeImage(at index: Int) {
        guard index < form.selectedImages.count else { return }
        form.selectedImages.remove(at: index)
    }
}
