//
//  CreateAdView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

// Views/CreateAdView.swift
// Views/CreateAdView.swift
import SwiftUI

struct CreateAdView: View {
    @StateObject private var viewModel = CreateAdViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                detailsSection
//                photosSection
                publishSection
            }
            .navigationTitle("Новое объявление")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert("Ошибка", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
                Button("OK") {
                    viewModel.errorMessage = ""
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Успех", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Объявление успешно создано!")
            }
//            .sheet(isPresented: $showingImagePicker) {
//                ImagePickerView { images in
//                    viewModel.addImages(images)
//                }
//            }
        }
    }
    
    // MARK: - Sections
    
    private var basicInfoSection: some View {
        Section(header: Text("Основная информация")) {
            TextField("Название объявления", text: $viewModel.form.title)
                .textInputAutocapitalization(.words)
            
            VStack(alignment: .leading) {
                Text("Описание")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.form.description)
                        .frame(minHeight: 100)
                    
                    if viewModel.form.description.isEmpty {
                        Text("Опишите ваш товар...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                }
            }
            
            TextField("Цена", text: $viewModel.form.price)
                .keyboardType(.decimalPad)
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text("Детали")) {
            Picker("Категория", selection: $viewModel.form.category) {
                ForEach(Category.allCases.filter { $0 != .allCathegories }, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            
            TextField("Город", text: $viewModel.form.city)
        }
    }
    
//    private var photosSection: some View {
//        Section(header: Text("Фотографии")) {
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
//                ForEach(Array(viewModel.form.selectedImages.enumerated()), id: \.offset) { index, image in
//                    ImageThumbnailView(
//                        image: image,
//                        onDelete: { viewModel.removeImage(at: index) }
//                    )
//                }
                
//                if viewModel.form.selectedImages.count < 3 {
//                    Button(action: { showingImagePicker = true }) {
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
//                            .frame(height: 80)
//                            .overlay(
//                                Image(systemName: "plus")
//                                    .font(.title2)
//                                    .foregroundColor(.gray)
//                            )
//                    }
//                }
//            }
//            .padding(.vertical, 8)
//
//    }
    
    private var publishSection: some View {
        Section {
            Button(action: {
                viewModel.createAd()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Опубликовать объявление")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.canSubmit)
            .buttonStyle(.borderedProminent)
        }
        .listRowBackground(Color.clear)
    }
}
