//
//  ProductViewModel.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 11.10.25.


import Foundation
internal import Combine
import SwiftUI

@MainActor
class CatalogViewModel: ObservableObject {
    @Published var advertisements: [Advertisement] = []
    @Published var filteredAds: [Advertisement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory = "Все категории"
    @Published var selectedSort = "Сначала новые"
    
    // Фильтры
    @Published var minPrice: String = ""
    @Published var maxPrice: String = ""
    @Published var selectedCity: String = ""
    @Published var selectedBrand: String = ""
    
    private let adService: AdServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    let categories = ["Все категории", "Автомобили с пробегом", "Новые автомобили", "Б/у запчасти для авто", "Спецтехника", "Шины и диски", "Грузовой транспорт", "Электромобили"]
    
    let sortOptions = ["Сначала новые", "Сначала старые", "Цена по возрастанию", "Цена по убыванию"]
    
    let cities = ["Минск", "Гомель", "Брест", "Витебск", "Гродно", "Могилев", "Барановичи", "Борисов", "Орша", "Молодечно"]
    
    let brands = ["Audi", "BMW", "Ford", "Hyundai", "Kia", "Mercedes", "Nissan", "Renault", "Skoda", "Toyota", "Volkswagen", "Volvo"]
    
    init(adService: AdServiceProtocol = AdService()) {
        self.adService = adService
        setupBindings()
    }
    
    private func setupBindings() {
        // Подписка на изменения из AdService
        adService.allAdsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ads in
                print("🟡 CatalogViewModel получил \(ads.count) объявлений")
                self?.advertisements = ads
                self?.applyCurrentFilters()
            }
            .store(in: &cancellables)
        
        adService.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        adService.errorPublisher
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .assign(to: &$errorMessage)
        
        // Реактивный поиск и фильтрация
        Publishers.CombineLatest4(
            $searchText,
            $selectedCategory,
            $selectedSort,
            $advertisements
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .map { [weak self] searchText, category, sort, ads -> [Advertisement] in
            let filtered = self?.applyFiltersAndSearch(to: ads, searchText: searchText, category: category, sort: sort) ?? ads
            print("🟡 После фильтрации: \(filtered.count) объявлений")
            return filtered
        }
        .assign(to: &$filteredAds)
        
        // Реакция на изменения фильтров цены, города и бренда
        Publishers.CombineLatest4(
            $minPrice,
            $maxPrice,
            $selectedCity,
            $selectedBrand
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.applyCurrentFilters()
        }
        .store(in: &cancellables)
    }
    
    private func applyCurrentFilters() {
        let filtered = applyFiltersAndSearch(
            to: advertisements,
            searchText: searchText,
            category: selectedCategory,
            sort: selectedSort
        )
        print("🟡 Текущие фильтры применены: \(filtered.count) объявлений")
        filteredAds = filtered
    }
    
    private func applyFiltersAndSearch(to ads: [Advertisement], searchText: String, category: String, sort: String) -> [Advertisement] {
        var filtered = ads
        
        print("🟡 Начало фильтрации: \(ads.count) объявлений")
        
        // Поиск по тексту
        if !searchText.isEmpty {
            filtered = filtered.filter { ad in
                ad.title.localizedCaseInsensitiveContains(searchText) ||
                ad.description.localizedCaseInsensitiveContains(searchText) ||
                ad.brand?.localizedCaseInsensitiveContains(searchText) == true ||
                ad.model?.localizedCaseInsensitiveContains(searchText) == true
            }
            print("🟡 После поиска '\(searchText)': \(filtered.count) объявлений")
        }
        
        // Фильтрация по категории
        if category != "Все категории" {
            filtered = filtered.filter { $0.category == category }
            print("🟡 После фильтра категории '\(category)': \(filtered.count) объявлений")
        }
        
        // Фильтрация по цене
        if let min = Double(minPrice) {
            filtered = filtered.filter { $0.price >= min }
            print("🟡 После мин. цены \(min): \(filtered.count) объявлений")
        }
        if let max = Double(maxPrice) {
            filtered = filtered.filter { $0.price <= max }
            print("🟡 После макс. цены \(max): \(filtered.count) объявлений")
        }
        
        // Фильтрация по городу
        if !selectedCity.isEmpty {
            filtered = filtered.filter { $0.city == selectedCity }
            print("🟡 После фильтра города '\(selectedCity)': \(filtered.count) объявлений")
        }
        
        // Фильтрация по бренду
        if !selectedBrand.isEmpty {
            filtered = filtered.filter { $0.brand == selectedBrand }
            print("🟡 После фильтра бренда '\(selectedBrand)': \(filtered.count) объявлений")
        }
        
        // Сортировка
        switch sort {
        case "Сначала старые":
            filtered.sort { $0.createdAt < $1.createdAt }
        case "Цена по возрастанию":
            filtered.sort { $0.price < $1.price }
        case "Цена по убыванию":
            filtered.sort { $0.price > $1.price }
        default: // "Сначала новые"
            filtered.sort { $0.createdAt > $1.createdAt }
        }
        
        print("✅ Финальный результат фильтрации: \(filtered.count) объявлений")
        return filtered
    }
    
    func resetFilters() {
        selectedCategory = "Все категории"
        selectedSort = "Сначала новые"
        minPrice = ""
        maxPrice = ""
        selectedCity = ""
        selectedBrand = ""
        searchText = ""
        print("🟡 Фильтры сброшены")
    }
    
    var hasActiveFilters: Bool {
        selectedCategory != "Все категории" ||
        !minPrice.isEmpty ||
        !maxPrice.isEmpty ||
        !selectedCity.isEmpty ||
        !selectedBrand.isEmpty ||
        selectedSort != "Сначала новые"
    }
    
    func refresh() {
        print("🟡 Принудительное обновление каталога")
        Task {
            await adService.loadAds()
        }
    }
    
    func listenToAds() {
        print("🟡 Запуск слушателя объявлений")
        adService.listenToAllAds()
    }
    
    func stopListening() {
        print("🟡 Остановка слушателя объявлений")
        adService.stopListening()
    }
}
