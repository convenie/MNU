//
//  SignUpView.swift
//  MoneyNotUse
//
//  Created by Yuri Mizui on 2024/12/14.
//


import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isRegistered = false
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text(errorMessage)
                .foregroundColor(.red)
            
            Button(action: registerUser) {
                Text("Sign Up")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
            
            // ログイン画面への遷移
            NavigationLink(destination: LoginView(), isActive: $isRegistered) {
                EmptyView()
            }
        }
        .padding()
    }
    
    // Firebaseで新規登録を行う
    func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription  // エラーメッセージを表示
            } else {
                // 新規登録成功
                errorMessage = ""
                isRegistered = true  // 登録後にログイン画面に遷移
            }
        }
    }
}
