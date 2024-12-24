//
//  MNUApp.swift
//  MNU
//
//  Created by Yuri Mizui on 2024/12/22.
//

import SwiftUI
import Firebase // Firebaseのインポートを忘れない

@main
struct MNUApp: App {
    // アプリの初期化処理
    init() {
        FirebaseApp.configure() // Firebaseの初期化
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
