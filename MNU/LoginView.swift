import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false

    var body: some View {
        VStack {
            if isLoggedIn {
                // ログイン成功した場合はホーム画面に遷移
                HomeView()
            } else {
                // ログイン画面
                NavigationView {
                    VStack {
                        // 中央揃えのタイトル
                        VStack(spacing: 8) {
                            Text("MoneyNotUse") // アプリ名
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center) // 中央揃え
                            Text("ログイン") // サブタイトル
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 30) // タイトルとフォームの間の余白

                        // 入力フォーム
                        VStack(spacing: 16) {
                            TextField("Email", text: $email)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress) // メールアドレス用のキーボードを表示

                            SecureField("Password", text: $password)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        // エラーメッセージ
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }

                        // ボタンを横並び
                        HStack(spacing: 40) { // ボタン間のスペース
                            Button(action: loginUser) {
                                Text("ログイン")
                                    .font(.headline)
                                    .padding()
                                    .frame(minWidth: 100) // ボタンの最小幅
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }

                            NavigationLink(destination: SignUpView()) {
                                Text("新規登録")
                                    .font(.headline)
                                    .padding()
                                    .frame(minWidth: 100) // ボタンの最小幅
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 20) // ボタン群の上に余白
                    }
                    .padding()
                    .navigationBarHidden(true) // ナビゲーションバーを非表示
                }
            }
        }
    }

    func loginUser() {
        // Firebaseでログインを試みる
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription  // エラーメッセージを表示
            } else {
                // ログイン成功
                errorMessage = ""
                isLoggedIn = true  // ログイン後にHomeViewに遷移
            }
        }
    }
}
