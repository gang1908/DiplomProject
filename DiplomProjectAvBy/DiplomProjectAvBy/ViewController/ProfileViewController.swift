//
//  CatalogViewController.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 11.10.25.
//

//
//  ProfileViewController.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 11.10.25.
//

import SwiftUI
import FirebaseAuth

struct ProfileViewController: View {
    @State private var isEditingEnabled = false
    @EnvironmentObject var authModel: AuthModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showingLogin = false
    @State private var showingEditProfile = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if authModel.isLoggedIn {
                    authenticatedView
                } else {
                    unauthenticatedView
                }
            }
        } else {
            NavigationView {
                if authModel.isLoggedIn {
                    authenticatedView
                } else {
                    unauthenticatedView
                }
            }
        }
    }
    
    // MARK: - Авторизованный вид
    private var authenticatedView: some View {
        Form {
            Section("Профиль") {
                VStack {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(authModel.loginName.isEmpty ? "Пользователь" : authModel.loginName)
                                .font(.headline)
                            Text(authModel.email.isEmpty ? "email@example.com" : authModel.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Button("Изменить") {
                            showingEditProfile = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section("Мои объявления") {
                if profileViewModel.isLoading {
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity)
                } else if profileViewModel.userAds.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("У вас пока нет объявлений")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                } else {
                    ForEach(profileViewModel.userAds) { ad in
                        NavigationLink(destination: AdDetailView(ad: ad)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ad.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(ad.formattedPrice)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                HStack {
                                    Text(ad.city)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(ad.category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            Section {
                Button("Выйти из аккаунта", role: .destructive) {
                    authModel.signOut()
                    profileViewModel.stopListening()
                }
            }
        }
        .navigationTitle("Мой Профиль")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Обновить") {
                    profileViewModel.loadUserAds()
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(authModel)
        }
        .onAppear {
            if authModel.isLoggedIn {
                profileViewModel.loadUserAds()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewAdCreated"))) { _ in
            // Обновляем профиль при создании нового объявления
            if authModel.isLoggedIn {
                profileViewModel.refreshUserAds()
            }
        }
    }
    
    // MARK: - Неавторизованный вид
    private var unauthenticatedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("Войдите в аккаунт")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Чтобы просматривать свой профиль и управлять объявлениями")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button("Войти") {
                showingLogin = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingLogin) {
            AuthController()
                .environmentObject(authModel)
        }
    }
}

// MARK: - Вью для редактирования профиля
struct EditProfileView: View {
    @EnvironmentObject var authModel: AuthModel
    @Environment(\.dismiss) private var dismiss
    @State private var editedName: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация профиля") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(authModel.email)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Имя пользователя")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Введите имя", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveProfile()
                    }
                    .disabled(editedName.isEmpty)
                }
            }
            .onAppear {
                editedName = authModel.loginName
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveProfile() {
        guard !editedName.isEmpty else {
            errorMessage = "Имя не может быть пустым"
            showingError = true
            return
        }
        
        authModel.updateUserProfile(name: editedName)
        dismiss()
    }
}
