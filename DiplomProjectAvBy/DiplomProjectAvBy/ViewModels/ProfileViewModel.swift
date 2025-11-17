//
//  ProfileViewModel.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 3.11.25.
//

//
//  ProfileViewModel.swift
//  DiplomProjectAvBy
//

import Foundation
import FirebaseAuth
internal import Combine
import FirebaseFirestore


@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userAds: [Advertisement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func loadUserAds() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Пользователь не авторизован"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🟡 Загружаем объявления пользователя: \(userId)")
        
        // Останавливаем предыдущий слушатель
        listener?.remove()
        
        // Слушаем в реальном времени
        listener = db.collection("ads")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Ошибка загрузки объявлений: \(error.localizedDescription)"
                    print("❌ Ошибка загрузки объявлений: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.userAds = []
                    print("ℹ️ Нет документов для пользователя")
                    return
                }
                
                let ads = documents.compactMap { document -> Advertisement? in
                    do {
                        let ad = try document.data(as: Advertisement.self)
                        print("✅ Загружено объявление: \(ad.title) - \(ad.id ?? "no id")")
                        return ad
                    } catch {
                        print("❌ Ошибка парсинга объявления: \(error)")
                        return nil
                    }
                }
                
                self.userAds = ads
                print("✅ Всего загружено \(ads.count) объявлений пользователя")
                self.errorMessage = nil
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
