//
//  FavoriteView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 2.11.25.
//

// Views/Components/FavoriteAdRowView.swift
import SwiftUI

struct FavoriteAdRowView: View {
    let ad: Advertisement
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
//            adImage
            
            VStack(alignment: .leading, spacing: 6) {
                Text(ad.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(ad.city)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack {
                    Text(ad.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button(action: onToggleFavorite) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
//    private var adImage: some View {
//        // ... тот же код для изображения
//    }
}

struct LoadingRowView: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Загрузка...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

