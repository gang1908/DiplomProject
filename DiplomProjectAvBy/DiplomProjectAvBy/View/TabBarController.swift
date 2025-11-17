//
//  TabBarController.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 15.10.25.
//

import SwiftUI

struct TabBarController: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authModel: AuthModel // Добавьте это
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Каталог
            CatalogViewController()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Каталог")
                }
                .tag(0)
            
            // Добавить
            CreateAdView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить")
                }
                .tag(1)
            
            // Избранное
            FavoriteViewController()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Избранное")
                }
                .tag(2)
            
            // Профиль
            ProfileViewController()
                .environmentObject(authModel) // Передаем в профиль
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}
