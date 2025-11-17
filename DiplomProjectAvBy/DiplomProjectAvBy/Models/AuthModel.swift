//
//  AuthModel.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 14.10.25.
//

import SwiftUI
internal import Combine
import FirebaseAuth

class AuthModel: ObservableObject {
    @Published var isLoggedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
            if isLoggedIn {
                // Сохраняем данные пользователя при входе
                saveUserData()
            }
        }
    }
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var loginName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showRegistration = false
    
    private let authService = AuthentificationService()
    
    init() {
        // Небольшая задержка для инициализации Firebase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkAuthState()
        }
    }
    
    private func checkAuthState() {
        if let user = Auth.auth().currentUser {
            print("✅ Firebase user found, setting isLoggedIn to true")
            self.isLoggedIn = true
            // Загружаем данные пользователя из Firebase
            self.loadUserData(from: user)
        } else {
            // Fallback на UserDefaults если Firebase не инициализирован
            let savedState = UserDefaults.standard.bool(forKey: "isLoggedIn")
            print("📱 Auth state from UserDefaults: \(savedState)")
            self.isLoggedIn = savedState
            
            // Если сохранено состояние входа, загружаем данные из UserDefaults
            if savedState {
                self.loadUserDataFromDefaults()
            }
        }
    }
    
    private func loadUserData(from user: User) {
        self.email = user.email ?? ""
        self.loginName = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "Пользователь"
        print("✅ User data loaded from Firebase: \(self.loginName), \(self.email)")
    }
    
    private func loadUserDataFromDefaults() {
        self.email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        self.loginName = UserDefaults.standard.string(forKey: "userName") ?? "Пользователь"
        print("✅ User data loaded from UserDefaults: \(self.loginName), \(self.email)")
    }
    
    private func saveUserData() {
        // Сохраняем в UserDefaults для быстрого доступа
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(loginName, forKey: "userName")
        print("✅ User data saved: \(loginName), \(email)")
    }
    
    func handleSaveRegistration() {
        guard !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty,
              !loginName.isEmpty,
              password == confirmPassword else {
            if password != confirmPassword {
                errorMessage = "Пароли не совпадают"
            } else {
                errorMessage = "Пожалуйста, заполните все поля"
            }
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Пароль должен содержать минимум 6 символов"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Передаем имя пользователя при регистрации
                try await authService.createUser(withEmail: email, password: password, userName: loginName)
                await MainActor.run {
                    self.isLoading = false
                    self.isLoggedIn = true
                    self.saveUserData() // Сохраняем данные
                    self.clearFields()
                    print("✅ Registration successful for user: \(self.loginName)")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = self.handleAuthError(error)
                    print("❌ Registration error: \(error)")
                }
            }
        }
    }
    
    func handleSignIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.signIn(withEmail: email, password: password)
                
                // После успешного входа загружаем данные пользователя
                if let userData = authService.getCurrentUser() {
                    await MainActor.run {
                        self.email = userData.email
                        self.loginName = userData.name
                        self.isLoading = false
                        self.isLoggedIn = true
                        self.saveUserData() // Сохраняем данные
                        self.clearFields()
                        print("✅ Sign in successful for user: \(userData.name)")
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = self.handleAuthError(error)
                    print("❌ Sign in error: \(error)")
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            clearFields()
            // Очищаем сохраненные данные
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "userName")
            print("✅ Signed out successfully")
        } catch {
            errorMessage = "Ошибка при выходе: \(error.localizedDescription)"
            print("❌ Sign out error: \(error)")
        }
    }
    
    private func clearFields() {
        password = ""
        confirmPassword = ""
        // Не очищаем email и loginName, так как они могут понадобиться
    }
    
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .emailAlreadyInUse:
                return "Этот email уже используется"
            case .userNotFound:
                return "Пользователь не найден"
            case .wrongPassword:
                return "Неверный пароль"
            case .invalidEmail:
                return "Неверный формат email"
            case .weakPassword:
                return "Пароль слишком слабый"
            case .networkError:
                return "Ошибка сети. Проверьте подключение"
            default:
                return "Произошла ошибка: \(error.localizedDescription)"
            }
        }
        return "Произошла ошибка: \(error.localizedDescription)"
    }
    
    // Метод для обновления данных пользователя
    func updateUserProfile(name: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { [weak self] error in
            if let error = error {
                print("❌ Error updating profile: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.loginName = name
                    self?.saveUserData()
                    print("✅ User profile updated: \(name)")
                }
            }
        }
    }
}
