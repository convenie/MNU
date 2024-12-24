//
//  MyPageView.swift
//  MoneyNotUse
//
//  Created by Yuri Mizui on 2024/12/15.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyPageView: View {
    @Binding var isLoggedOut: Bool
    @State private var balance: Double?  // 残高
    @State private var showBalanceUpdateView = false  // 残高更新画面の表示フラグ

    var body: some View {
        VStack(spacing: 20) {
            Text("マイページ")
                .font(.largeTitle)
                .padding()

            Text("本日: \(formattedDate(Date()))")
                .font(.headline)

            if let user = Auth.auth().currentUser {
                Text("アカウント: \(user.email ?? "No Email")")
                    .font(.subheadline)
            }
            

            // ログアウトボタン
            Button(action: logoutUser) {
                Text("ログアウト")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            
        }
        .padding()
    }

    // ログアウト処理
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch let error {
            print("ログアウトに失敗しました: \(error.localizedDescription)")
        }
    }

    // 日付フォーマット
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(isLoggedOut: .constant(false))
    }
}
