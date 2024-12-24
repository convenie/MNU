import SwiftUI
import Firebase
import FirebaseAuth

struct HistoryTabView: View {
    @Binding var history: [HistoryEntry]
    @State private var selectedAmount: Double? = nil
    @State private var selectedDate: String? = nil
    @State private var isPopupVisible: Bool = false // ポップアップ表示のフラグ

    var body: some View {
        VStack {
            Text("履歴")
                .font(.title2)
                .foregroundColor(.blue)

            // 金額と日時、削除ボタンをリスト表示
            List {
                ForEach(history, id: \.id) { entry in
                    HStack {
                        // 左側に金額
                        Text("\(entry.amount, specifier: "%.1f")円")
                            .font(.body)
                            .foregroundColor(.black)
                            .frame(width: 100, alignment: .leading)

                        Spacer()

                        // 右側に日時
                        Text(entry.date)
                            .font(.body)
                            .foregroundColor(.gray)
                            .frame(width: 150, alignment: .trailing)

                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectedAmount = entry.amount
                        self.selectedDate = entry.date // 日付も保存
                        self.isPopupVisible = true // ポップアップ表示
                    }
                }
                .onDelete(perform: deleteHistory)
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchHistory()
        }
        // ポップアップを表示
        .sheet(isPresented: $isPopupVisible) {
            // ポップアップ内で表示するビュー
            PopupView(amount: self.selectedAmount ?? 0, isVisible: self.$isPopupVisible)
        }
    }

    // 履歴の削除処理
    private func deleteHistoryEntry(_ entry: HistoryEntry) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        // Firestoreから履歴を削除
        db.collection("Users").document(user.uid).collection("History")
            .whereField("amount", isEqualTo: entry.amount)
            .whereField("date", isEqualTo: entry.date)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("履歴の削除に失敗しました: \(error.localizedDescription)")
                    return
                }
                if let document = snapshot?.documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("削除エラー: \(error.localizedDescription)")
                        } else {
                            print("履歴が削除されました。")
                        }
                    }
                }
            }
    }

    // Firestoreから履歴を取得
    private func fetchHistory() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        db.collection("Users").document(user.uid).collection("History")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("履歴の取得に失敗しました: \(error.localizedDescription)")
                    return
                }
                self.history = snapshot?.documents.compactMap { doc in
                    if let amount = doc["amount"] as? Double,
                       let date = doc["date"] as? String {
                        return HistoryEntry(amount: amount, date: date)
                    }
                    return nil
                } ?? []
            }
    }

    // 履歴削除のための配列変更
    private func deleteHistory(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = history[index]
            deleteHistoryEntry(entry)
        }
        history.remove(atOffsets: offsets)
    }
}

// PopupViewの修正部分
struct PopupView: View {
    var amount: Double
    @Binding var isVisible: Bool // ポップアップの表示非表示フラグ

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.isVisible = false // ポップアップを閉じる
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
            .padding()

            Spacer()

            // 金額の表示
            Text("金額: \(amount, specifier: "%.1f")円")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.primary) // 動的に文字色を変更

            // 残高に応じた財布の中身を表示
            WalletView(balance: Int(amount))  // 直接Intに変換して渡す


            Spacer()
        }
        .background(Color("PopupBackground")) // カスタムカラー
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(30)
    }
}
