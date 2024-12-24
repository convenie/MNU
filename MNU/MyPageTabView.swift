import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyPageTabView: View {
    @Binding var isLoggedOut: Bool
    @State private var balance: Double? // 残高
    @State private var showBalanceUpdateView = false // 残高更新画面の表示フラグ
    @State private var monthlyIncome: Double = 0.0 // 月の入金金額
    @State private var monthlyExpense: Double = 0.0 // 月の出金金額
    
    @State private var isNotificationEnabled = false // 通知設定
    @State private var selectedLanguage = "日本語" // 言語設定
    let languages = ["日本語", "English", "Español"]
    
    @State private var showAccountDeleteAlert = false // アカウント削除確認アラート
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // プロフィール画像と名前
                if let user = Auth.auth().currentUser {
                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text(user.email ?? "No Email")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
                
                // 日付表示
                Text("\(formattedDate(Date()))")
                    .font(.headline)
                
                // 月の入金金額・出金金額表示
                VStack {
                    Text("今月の入金金額: \(String(format: "%.2f", monthlyIncome))円")
                    Text("今月の出金金額: \(String(format: "%.2f", monthlyExpense))円")
                }
                .font(.subheadline)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                // 通知設定
                Toggle(isOn: $isNotificationEnabled) {
                    Text("通知を有効にする")
                        .font(.headline)
                }
                .padding()
                
                // アカウント削除ボタン
                Button(action: {
                    showAccountDeleteAlert = true
                }) {
                    Text("アカウント削除")
                }
                .alert(isPresented: $showAccountDeleteAlert) {
                    Alert(
                        title: Text("アカウント削除"),
                        message: Text("本当にアカウントを削除しますか？この操作は取り消せません。"),
                        primaryButton: .destructive(Text("削除")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                // 問い合わせリンク
                NavigationLink(destination: ContactFormView()) {
                    Text("問い合わせ")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // ログアウトボタン
                Button(action: logoutUser) {
                    Text("ログアウト")
                }
            }
            .padding()
        }
        .onAppear {
            fetchMonthlyIncomeAndExpense()
        }
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
    
    // アカウント削除処理
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        user.delete { error in
            if let error = error {
                print("アカウント削除に失敗しました: \(error.localizedDescription)")
            } else {
                print("アカウントが正常に削除されました")
                isLoggedOut = true
            }
        }
    }
    
    // 今月の入金金額・出金金額を取得
    func fetchMonthlyIncomeAndExpense() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        db.collection("transactions")
            .whereField("userId", isEqualTo: userId)
            .whereField("month", isEqualTo: currentMonth)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("データ取得エラー: \(error.localizedDescription)")
                    return
                }
                
                var income = 0.0
                var expense = 0.0
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    let amount = data["amount"] as? Double ?? 0.0
                    let type = data["type"] as? String ?? ""
                    
                    if type == "income" {
                        income += amount
                    } else if type == "expense" {
                        expense += amount
                    }
                }
                
                self.monthlyIncome = income
                self.monthlyExpense = expense
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
