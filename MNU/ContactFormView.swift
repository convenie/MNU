//
//  ContactFormView.swift
//  MoneyNotUse
//
//  Created by Yuri Mizui on 2024/12/21.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContactFormView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var successMessage: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            TextField("お名前", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("メールアドレス", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
            
            TextEditor(text: $message)
                .frame(height: 150)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(8)
            
            Button(action: submitForm) {
                Text("送信")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
    
    func submitForm() {
        guard !name.isEmpty, !email.isEmpty, !message.isEmpty else {
            errorMessage = "すべてのフィールドを入力してください。"
            return
        }
        
        let db = Firestore.firestore()
        let contactRef = db.collection("contacts").document()
        
        let contactData: [String: Any] = [
            "name": name,
            "email": email,
            "message": message,
            "timestamp": Timestamp(),
            "status": "未対応"  // 管理者が確認するまでの状態
        ]
        
        contactRef.setData(contactData) { error in
            if let error = error {
                errorMessage = "送信に失敗しました: \(error.localizedDescription)"
            } else {
                successMessage = "送信が完了しました。管理者が確認します。"
                clearForm()
            }
        }
    }
    
    func clearForm() {
        name = ""
        email = ""
        message = ""
    }
}

struct ContactFormView_Previews: PreviewProvider {
    static var previews: some View {
        ContactFormView()
    }
}
