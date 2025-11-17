//
//  DiplomProjectAvByApp.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 5.10.25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct DiplomProjectAvBy: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authModel = AuthModel()
    
    var body: some Scene {
        WindowGroup {
            if authModel.isLoggedIn {
                TabBarController()
                    .environmentObject(authModel)
            } else {
                AuthController()
                    .environmentObject(authModel)
            }
        }
    }
}
