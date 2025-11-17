//
//  RegistrationController.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 15.10.25.
//

import SwiftUI

struct RegistrationController: View {
    @EnvironmentObject var authModel: AuthModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Заголовок
                Text("Регистрация")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)
                
                // Поля ввода
                VStack(alignment: .leading, spacing: 8) {
                    Text("Имя пользователя")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Введите имя пользователя", text: $authModel.loginName)
                        .textContentType(.givenName)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    SecureField("Повторите пароль", text: $authModel.confirmPassword)
                        .textContentType(.password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                if !authModel.errorMessage.isEmpty {
                    Text(authModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                Button("Save") {
                    authModel.handleSaveRegistration()
                }
                .disabled(authModel.isLoading)
                .frame(maxWidth: .infinity)
                .padding()
                .background(authModel.isLoading ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                // Добавьте кнопку отмены
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.gray)
            }
            .padding(30)
        }
    }
}
