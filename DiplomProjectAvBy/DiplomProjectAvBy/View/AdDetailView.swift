//
//  AdDetailView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 2.11.25.
//

import SwiftUI

import SwiftUI
import FirebaseAuth

struct AdDetailView: View {
    let ad: Advertisement
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @State private var selectedImageIndex = 0
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Галерея изображений
                imageGallery
                
                // Основная информация
                mainInfoSection
                
                // Описание
                descriptionSection
                
                // Характеристики
                specificationsSection
                
                // Информация о продавце
                sellerSection
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        .alert("Ошибка", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            checkAuthAndLoadFavorites()
        }
        .onDisappear {
            favoritesViewModel.stopListening()
        }
        .onChange(of: favoritesViewModel.showErrorAlert) { newValue in
            if newValue {
                errorMessage = favoritesViewModel.errorMessage ?? "Неизвестная ошибка"
                showErrorAlert = true
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var favoriteButton: some View {
        Button(action: {
            toggleFavorite()
        }) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: getHeartIconName())
                    .foregroundColor(getHeartColor())
            }
        }
        .disabled(isLoading || !isUserAuthenticated())
    }
    
    private func isUserAuthenticated() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    private func checkAuthAndLoadFavorites() {
        if let user = Auth.auth().currentUser {
            favoritesViewModel.loadFavorites()
        } else {
            errorMessage = "Для добавления в избранное необходимо войти в аккаунт"
            showErrorAlert = true
        }
    }
    
    private func getHeartIconName() -> String {
        if !isUserAuthenticated() {
            return "heart"
        }
        return favoritesViewModel.isFavorite(adId: ad.id ?? "") ? "heart.fill" : "heart"
    }
    
    private func getHeartColor() -> Color {
        if !isUserAuthenticated() {
            return .gray
        }
        return favoritesViewModel.isFavorite(adId: ad.id ?? "") ? .red : .primary
    }
    
    // MARK: - Функция добавления/удаления из избранного
    private func toggleFavorite() {
        guard isUserAuthenticated() else {
            errorMessage = "Для добавления в избранное необходимо войти в аккаунт"
            showErrorAlert = true
            return
        }
        
        guard let adId = ad.id, !adId.isEmpty else {
            errorMessage = "Ошибка: у объявления нет ID"
            showErrorAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            let success = await favoritesViewModel.toggleFavorite(ad: ad)
            
            await MainActor.run {
                isLoading = false
                
                if success {
                    let isNowFavorite = favoritesViewModel.isFavorite(adId: adId)
                } else {
                    // Показываем ошибку из ViewModel
                    if let error = favoritesViewModel.errorMessage {
                        errorMessage = error
                        showErrorAlert = true
                    }
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    private var imageGallery: some View {
        VStack {
            if ad.imageUrls.isEmpty {
                placeholderImage
                    .frame(height: 250)
            } else {
                TabView(selection: $selectedImageIndex) {
                    ForEach(0..<ad.imageUrls.count, id: \.self) { index in
                        AsyncImage(url: URL(string: ad.imageUrls[index])) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .empty:
                                ProgressView()
                            case .failure:
                                placeholderImage
                            @unknown default:
                                placeholderImage
                            }
                        }
                        .tag(index)
                    }
                }
                .frame(height: 250)
                .tabViewStyle(PageTabViewStyle())
                
                if ad.imageUrls.count > 1 {
                    HStack {
                        ForEach(0..<ad.imageUrls.count, id: \.self) { index in
                            Circle()
                                .fill(index == selectedImageIndex ? Color.blue : Color.gray)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "car.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
            )
    }
    
    private var mainInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ad.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(ad.formattedPrice)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                Text(ad.city)
                Spacer()
                Text(ad.condition)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
            }
            .foregroundColor(.secondary)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            
            Text(ad.description)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
    
    private var specificationsSection: some View {
        Group {
            if hasSpecifications {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Характеристики")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        if let brand = ad.brand {
                            specificationRow(title: "Марка", value: brand)
                        }
                        if let model = ad.model {
                            specificationRow(title: "Модель", value: model)
                        }
                        if let year = ad.year {
                            specificationRow(title: "Год", value: "\(year)")
                        }
                        if let mileage = ad.mileage {
                            specificationRow(title: "Пробег", value: "\(mileage.formatted()) км")
                        }
                        if let engineVolume = ad.engineVolume {
                            specificationRow(title: "Двигатель", value: "\(engineVolume) л")
                        }
                        if let fuelType = ad.fuelType {
                            specificationRow(title: "Топливо", value: fuelType)
                        }
                        if let transmission = ad.transmission {
                            specificationRow(title: "Коробка", value: transmission)
                        }
                    }
                }
            }
        }
    }
    
    private var hasSpecifications: Bool {
        ad.brand != nil || ad.model != nil || ad.year != nil || ad.mileage != nil ||
        ad.engineVolume != nil || ad.fuelType != nil || ad.transmission != nil
    }
    
    private func specificationRow(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private var sellerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Продавец")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(ad.userName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(ad.userEmail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Показать телефон
                }) {
                    Text("Показать телефон")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
