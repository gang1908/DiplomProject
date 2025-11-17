//
//  ImageView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

//import SwiftUI
//
//// Компонент для отображения миниатюры изображения
//struct ImageThumbnailView: View {
//    let image: UIImage
//    let onDelete: () -> Void
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 80, height: 80)
//                .cornerRadius(8)
//            
//            deleteButton
//        }
//    }
//    
//    private var deleteButton: some View {
//        Button(action: onDelete) {
//            Image(systemName: "xmark.circle.fill")
//                .foregroundColor(.red)
//                .background(Color.white)
//                .clipShape(Circle())
//        }
//        .offset(x: 8, y: -8)
//    }
//}
