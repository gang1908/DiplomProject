//
//  ContentView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 5.10.25.
//

import SwiftUI

struct CatalogViewController: View {
    @StateObject private var viewModel = CatalogViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Панель поиска
                searchField
                
                // Информация о фильтрах
                filterInfoView
                
                // Список объявлений
                adsList
            }
            .navigationTitle("AV.BY")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .sheet(isPresented: $showingFilters) {
                FiltersView(viewModel: viewModel)
            }
            .overlay {
                if viewModel.isLoading && viewModel.advertisements.isEmpty {
                    ProgressView("Загрузка объявлений...")
                        .scaleEffect(1.2)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(10)
                }
            }
            .onAppear {
                viewModel.listenToAds() // Загружаем в реальном времени
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
    
    // MARK: - Компоненты
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Поиск автомобилей...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var filterInfoView: some View {
        Group {
            if viewModel.hasActiveFilters {
                HStack {
                    Text("Активные фильтры")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Сбросить") {
                        viewModel.resetFilters()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    private var adsList: some View {
        Group {
            if viewModel.filteredAds.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    emptyStateView
                }
            } else {
                List(viewModel.filteredAds) { ad in
                    NavigationLink(destination: AdDetailView(ad: ad)) {
                        AdRowView(ad: ad)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    viewModel.refresh()
                }
            }
        }
    }
    
    private var filterButton: some View {
        Button(action: {
            showingFilters = true
        }) {
            Image(systemName: viewModel.hasActiveFilters ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                .foregroundColor(viewModel.hasActiveFilters ? .blue : .primary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("Объявления не найдены")
                    .font(.headline)
                
                Text("Попробуйте изменить параметры поиска или сбросить фильтры")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if viewModel.hasActiveFilters {
                Button("Сбросить фильтры") {
                    viewModel.resetFilters()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}


#Preview {
    CatalogViewController()
}
