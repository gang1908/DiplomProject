//
//  PhotoUpLoadView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

import SwiftUI

// Компонент для загрузки фотографий
struct PhotoUploadView: View {
    @ObservedObject var viewModel: CreateAdViewModel
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(alignment: .leading) {
            headerText
            imagesScrollView
        }
        .sheet(isPresented: $showImagePicker) {
//            ImagePickerView { images in
//                viewModel.addImages(images)
            }
        }
    
    
    private var headerText: some View {
        Text("До 3 фотографий")
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    private var imagesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                existingImages
                addButton
            }
        }
    }
    
    private var existingImages: some View {
        ForEach(0..<$viewModel.form.selectedImages.count, id: \.self) { index in
//            ImageThumbnailView(
//                image: $viewModel.form.selectedImages[index],
//                onDelete: { viewModel.removeImage(at: index) }
//            )
        }
    }
    
    private var addButton: some View {
        Group {
            if $viewModel.form.selectedImages.count < 3 {
                Button(action: { showImagePicker = true }) {
                    addButtonContent
                }
            }
        }
    }
    
    private var addButtonContent: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.gray)
            )
    }
}

#Preview {
    PhotoUploadView(viewModel: CreateAdViewModel())
}
