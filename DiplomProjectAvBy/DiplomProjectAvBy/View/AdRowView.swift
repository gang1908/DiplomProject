//
//  AdRowView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 19.10.25.
//

import SwiftUI

struct AdRowView: View {
    let ad: Advertisement
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Изображение
            adImage
            
            // Информация
            VStack(alignment: .leading, spacing: 4) {
                Text(ad.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(ad.city)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(ad.formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private var adImage: some View {
        Group {
            if let firstImageUrl = ad.imageUrls.first, let url = URL(string: firstImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        placeholderImage
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 100, height: 80)
        .cornerRadius(8)
        .clipped()
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "car.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            )
    }
}
