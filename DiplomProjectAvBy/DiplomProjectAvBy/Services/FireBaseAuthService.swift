//
//  FireBaseAuth.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 14.10.25.
//

import FirebaseCore
import FirebaseAuth

final class AuthentificationService {
    
    func createUser(withEmail email: String, password: String, userName: String) async throws {
        // Проверяем, что Firebase настроен
        guard FirebaseApp.app() != nil else {
            throw NSError(domain: "FirebaseError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Firebase not configured. Please restart the app."])
        }
        
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Обновляем профиль пользователя с именем
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = userName
        try await changeRequest.commitChanges()
        
        print("✅ User created: \(result.user.uid), name: \(userName)")
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        // Проверяем, что Firebase настроен
        guard FirebaseApp.app() != nil else {
            throw NSError(domain: "FirebaseError", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Firebase not configured. Please restart the app."])
        }
        
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        print("✅ User signed in: \(result.user.uid)")
    }
    
    // Метод для получения данных текущего пользователя
    func getCurrentUser() -> (email: String, name: String)? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        
        let email = user.email ?? ""
        let name = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "Пользователь"
        
        return (email: email, name: name)
    }
}

