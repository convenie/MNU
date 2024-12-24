//
//  InitialBalanceView.swift
//  MoneyNotUse
//
//  Created by Yuri Mizui on 2024/12/15.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct InitialBalanceView: View {
    @State private var balance: String = ""  // ユーザーが入力する残高
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode  // ナビゲーション戻る用

    var body: some View {
        VStack(spacing: 20) {
            Text("初期残高を登録してください")
                .font(.title)
                .padding()

            TextField("残高を入力", text: $balance)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: saveBalance) {
                Text("登録")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }

    // 残高を保存
    func saveBalance() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "ユーザーがログインしていません"
            return
        }

        guard let balanceValue = Double(balance), balanceValue >= 0 else {
            errorMessage = "有効な金額を入力してください"
            return
        }

        let db = Firestore.firestore()
        db.collection("Users").document(user.uid).setData([
            "balance": balanceValue
        ]) { error in
            if let error = error {
                errorMessage = "データの保存に失敗しました: \(error.localizedDescription)"
            } else {
                errorMessage = ""
                presentationMode.wrappedValue.dismiss()  // 登録成功後に戻る
            }
        }
    }
}

struct InitialBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        InitialBalanceView()
    }
}
