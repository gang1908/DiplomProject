//
//  FiltersView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 19.10.25.
//

// Views/FiltersView.swift
import SwiftUI

struct FiltersView: View {
    @ObservedObject var viewModel: CatalogViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                categorySection
                priceSection
                locationSection
                brandSection
                sortSection
                
                applyButton
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сбросить") {
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Sections (остается без изменений)
    private var categorySection: some View {
        Section(header: Text("Категория")) {
            Picker("Категория", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var priceSection: some View {
        Section(header: Text("Цена")) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Диапазон цен (руб.)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("От")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("0", text: $viewModel.minPrice)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("До")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Макс.", text: $viewModel.maxPrice)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Местоположение")) {
            Picker("Город", selection: $viewModel.selectedCity) {
                Text("Все города").tag("")
                ForEach(viewModel.cities, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var brandSection: some View {
        Section(header: Text("Марка автомобиля")) {
            Picker("Марка", selection: $viewModel.selectedBrand) {
                Text("Все марки").tag("")
                ForEach(viewModel.brands, id: \.self) { brand in
                    Text(brand).tag(brand)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var sortSection: some View {
        Section(header: Text("Сортировка")) {
            Picker("Сортировка", selection: $viewModel.selectedSort) {
                ForEach(viewModel.sortOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var applyButton: some View {
        Section {
            Button(action: {
                dismiss()
            }) {
                Text("Применить фильтры")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .listRowInsets(EdgeInsets())
            .padding(.horizontal, -16)
        }
        .listRowBackground(Color.clear)
    }
}

