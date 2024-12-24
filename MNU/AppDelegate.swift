//
//  AppDelegate.swift
//  MoneyNotUse
//
//  Created by Yuri Mizui on 2024/12/14.
//


import UIKit
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebaseの初期化
        FirebaseApp.configure()
        return true
    }
}
