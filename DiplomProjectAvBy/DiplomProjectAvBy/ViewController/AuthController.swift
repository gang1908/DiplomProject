//
//  AuthController.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 14.10.25.
//

import SwiftUI

struct AuthController: View {
    @EnvironmentObject var authModel: AuthModel // Должен быть доступен
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Заголовок
                Text("Авторизация")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)
                
                // Поля ввода
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("example@gmail.com", text: $authModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    SecureField("Введите пароль", text: $authModel.password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Сообщение об ошибке
                if !authModel.errorMessage.isEmpty {
                    Text(authModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Кнопки
                HStack(spacing: 15) {
                    Button("Sign In") {
                        authModel.handleSignIn()
                    }
                    .disabled(authModel.isLoading)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authModel.isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Registration") {
                        authModel.showRegistration = true
                    }
                    .disabled(authModel.isLoading)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authModel.isLoading ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 10)
                
                if authModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(30)
            .disabled(authModel.isLoading)
            .navigationDestination(isPresented: $authModel.isLoggedIn) {
                TabBarController()
                    .environmentObject(authModel) // Передаем дальше
            }
            .sheet(isPresented: $authModel.showRegistration) {
                RegistrationController()
                    .environmentObject(authModel) // Передаем в регистрацию
            }
        }
    }
}
