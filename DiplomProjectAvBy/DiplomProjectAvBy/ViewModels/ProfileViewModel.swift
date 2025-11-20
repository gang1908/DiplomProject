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
            userAds = [] // Очищаем список при отсутствии пользователя
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        
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
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.userAds = []
                    return
                }
            
                
                let ads = documents.compactMap { document -> Advertisement? in
                    do {
                        let ad = try document.data(as: Advertisement.self)
                        return ad
                    } catch {
                        return nil
                    }
                }
                
                self.userAds = ads
                self.errorMessage = nil
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func refreshUserAds() {
        loadUserAds()
    }
}
