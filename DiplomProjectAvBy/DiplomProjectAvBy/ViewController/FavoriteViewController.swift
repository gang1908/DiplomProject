//
//  FavoriteViewController.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 11.10.25.
//

// Views/FavoriteViewController.swift
// Views/FavoriteViewController.swift
import SwiftUI

struct FavoriteViewController: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var showingClearConfirmation = false
    @EnvironmentObject var authModel: AuthModel // Добавьте это
    
    var body: some View {
        NavigationView {
            ZStack {
                if !authModel.isLoggedIn {
                    notAuthenticatedView
                } else if viewModel.isLoading && viewModel.favoriteAds.isEmpty {
                    ProgressView("Загрузка избранного...")
                        .scaleEffect(1.2)
                } else if viewModel.favoriteAds.isEmpty {
                    emptyStateView
                } else {
                    favoritesListView
                }
            }
            .navigationTitle("Избранное")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if authModel.isLoggedIn && !viewModel.favoriteAds.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        clearAllButton
                    }
                }
            }
            .alert("Ошибка", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Неизвестная ошибка")
            }
            .confirmationDialog(
                "Очистить все избранное?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Очистить", role: .destructive) {
                    clearAllFavorites()
                }
                Button("Отмена", role: .cancel) { }
            }
            .onAppear {
                if authModel.isLoggedIn {
                    print("🟡 FavoriteView: Пользователь авторизован, загружаем избранное")
                    viewModel.loadFavorites()
                } else {
                    print("🔴 FavoriteView: Пользователь не авторизован")
                }
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
    
    // Добавьте view для неавторизованных пользователей
    private var notAuthenticatedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 12) {
                Text("Требуется авторизация")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Войдите в аккаунт чтобы просматривать избранные товары")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - View Components
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 12) {
                Text("Нет избранных товаров")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Добавляйте товары в избранное, нажимая на сердечко в карточке товара")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var favoritesListView: some View {
        List {
            ForEach(viewModel.favoriteAds) { favorite in
                if let ad = favorite.advertisement {
                    NavigationLink(destination: AdDetailView(ad: ad)) {
                        FavoriteAdRowView(
                            ad: ad,
                            isFavorite: true,
                            onToggleFavorite: {
                                toggleFavorite(ad: ad)
                            }
                        )
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            removeFromFavorites(adId: ad.id ?? "")
                        } label: {
                            Label("Удалить", systemImage: "heart.slash.fill")
                        }
                    }
                } else {
                    LoadingRowView()
                }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            viewModel.loadFavorites()
        }
    }
    
    private var clearAllButton: some View {
        Button(action: {
            showingClearConfirmation = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
        .disabled(viewModel.isLoading)
    }
    
    // MARK: - User Actions
    
    private func removeFromFavorites(adId: String) {
        Task {
            await viewModel.removeFromFavorites(adId: adId)
        }
    }
    
    private func toggleFavorite(ad: Advertisement) {
        Task {
            await viewModel.toggleFavorite(ad: ad)
        }
    }
    
    private func clearAllFavorites() {
        Task {
            await viewModel.clearAllFavorites()
        }
    }
}


#Preview {
    FavoriteViewController()
}
