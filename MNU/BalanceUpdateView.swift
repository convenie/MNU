import SwiftUI
import Firebase
import FirebaseAuth

struct BalanceUpdateView: View {
    @Binding var balance: Double?
    @Binding var inputAmount: String
    var onSave: () -> Void
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var currentDate = ""

    // 最大桁数
    private let maxDigits = 12

    var body: some View {
        VStack {
            Text("現在の残高")
                .font(.title)
            Text("\(balance ?? 0, specifier: "%.1f")円")
                .font(.title)

            // 入力された金額を表示
            Text(inputAmount)
                .font(.largeTitle)
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)

            // 電卓のボタン（テンキー）
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ForEach(1...3, id: \.self) { number in
                        Button("\(number)") { addDigit("\(number)") }
                            .buttonStyle(CalculatorButtonStyle())
                    }
                }
                HStack(spacing: 10) {
                    ForEach(4...6, id: \.self) { number in
                        Button("\(number)") { addDigit("\(number)") }
                            .buttonStyle(CalculatorButtonStyle())
                    }
                }
                HStack(spacing: 10) {
                    ForEach(7...9, id: \.self) { number in
                        Button("\(number)") { addDigit("\(number)") }
                            .buttonStyle(CalculatorButtonStyle())
                    }
                }
                HStack(spacing: 10) {
                    Button("C") {
                        inputAmount = "0"  // 入力内容をリセット
                    }
                    .buttonStyle(CalculatorButtonStyle())
                    Button("0") {
                        addDigit("0")
                    }
                    .buttonStyle(CalculatorButtonStyle())
                    Button("-") {
                        addMinusSign()
                    }
                    .buttonStyle(CalculatorButtonStyle())
                }
            }

            // 保存ボタン
            Button("保存") {
                if let amount = Double(inputAmount), amount != 0 {
                    let newBalance = (balance ?? 0) + amount
                    if newBalance < 0 {
                        // 残高が負にならないようにエラーチェック
                        showAlert = true
                        alertMessage = "残高は0未満にはできません。"
                    } else {
                        // 残高を更新
                        self.balance! += amount // ローカルで残高を更新
                        updateBalanceInFirestore(amount) // Firestoreにも更新
                        addHistory(amount) // 履歴に追加
                        onSave() // onSave クロージャを呼び出す
                        showAlert = true
                        alertMessage = "更新が完了しました。"
                    }
                }
            }
            .padding()
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("確認"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            // ページが表示されるたびに入力値を初期化
            inputAmount = "0"
            // 本日の日付を設定
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            currentDate = formatter.string(from: Date())
        }
    }

    // 数字を入力する関数
    private func addDigit(_ digit: String) {
        // 12桁を超える入力を防止
        if inputAmount.count >= maxDigits {
            return
        }
        
        // もし現在の入力が "0" で、次に入力されるのが "0" なら何もしない
        if inputAmount == "0" && digit == "0" {
            return
        }
        // もし現在の入力が "-0" で、次に入力されるのが "数字" なら何もしない
        if inputAmount == "-0" && digit != "-" {
            return
        }
        // 0の後に数字が入力された場合、"0" を消す
        if inputAmount == "0" && digit != "0" && digit != "-" {
            inputAmount = digit
        } else {
            inputAmount += digit
        }
    }

    // マイナス記号の追加
    private func addMinusSign() {
        // すでにマイナス記号が入力されている場合、追加しない
        if inputAmount.contains("-") {
            return
        }

        // 入力が "0" なら "-" だけを設定
        if inputAmount == "0" {
            inputAmount = "-"
        } else {
            inputAmount = "-" + inputAmount
        }

        // マイナス記号後に"0"が続かないように制御
        if inputAmount == "-0" {
            inputAmount = "-"
        }
    }

    // Firestoreで残高を更新する関数
    private func updateBalanceInFirestore(_ increment: Double) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        // Firestoreに残高を更新
        db.collection("Users").document(user.uid).updateData([
            "balance": FieldValue.increment(increment)
        ]) { error in
            if let error = error {
                print("残高の更新に失敗しました: \(error.localizedDescription)")
            } else {
                print("残高が正常に更新されました。")
            }
        }
    }

    // 履歴に追加する関数
    private func addHistory(_ amount: Double) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        // 履歴に金額と日時を追加
        db.collection("Users").document(user.uid).collection("History").addDocument(data: [
            "amount": amount,
            "date": currentDate
        ]) { error in
            if let error = error {
                print("履歴の追加に失敗しました: \(error.localizedDescription)")
            } else {
                print("履歴が正常に追加されました。")
            }
        }
    }
}

// カスタムボタンスタイル（電卓風のスタイル）
struct CalculatorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.black)
            .font(.title)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 保存ボタン用のカスタムスタイル
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
