import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import MNU

struct HomeView: View {
    @State private var userID = ""
    @State private var balance: Double? = nil
    @State private var selectedTab = 0
    @State private var showUpdateAlert = false
    @State private var history: [HistoryEntry] = []
    @State private var inputAmount: String = "0"
    @State private var showInitialBalanceView = false
    @State private var isLoggedOut = false

    var body: some View {
        NavigationView {
            ZStack { // レイアウトの変更
                TabView(selection: $selectedTab) {
                    HomeTabView(balance: $balance, inputAmount: $inputAmount, showUpdateAlert: $showUpdateAlert, showInitialBalanceView: $showInitialBalanceView)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("ホーム")
                        }
                        .tag(0)
                    
                    HistoryTabView(history: $history)
                        .tabItem {
                            Image(systemName: "clock.fill")
                            Text("履歴")
                        }
                        .tag(1)

                    NotificationsTabView()
                        .tabItem {
                            Image(systemName: "bell.fill")
                            Text("通知")
                        }
                        .tag(2)

                    CalendarTabView()
                        .tabItem {
                            Image(systemName: "calendar.fill")
                            Text("カレンダー")
                        }
                        .tag(3)

                    MyPageTabView(isLoggedOut: $isLoggedOut)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("マイページ")
                        }
                        .tag(4)
                }
                .accentColor(.blue)
                .edgesIgnoringSafeArea(.all) // 全体の余白を無視
                .onAppear {
                    // TabViewの透明性を削除
                    UITabBar.appearance().isTranslucent = false
                    // iOS 15以上でTabViewの余白を削除
                    UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
                }

                // 非表示にするNavigationLink
                NavigationLink(destination: LoginView(), isActive: $isLoggedOut) { EmptyView() }
                    .hidden()
                NavigationLink(destination: InitialBalanceView(), isActive: $showInitialBalanceView) { EmptyView() }
                    .hidden()
            }
            .onAppear {
                fetchUserID()
                fetchBalance()
                fetchHistory()
            }
            .onChange(of: balance) { _ in
                fetchBalance()
            }
            .alert(isPresented: $showUpdateAlert) {
                Alert(
                    title: Text("更新完了"),
                    message: Text("残高が正常に更新されました。"),
                    dismissButton: .default(Text("OK"), action: {
                        self.selectedTab = 0
                    })
                )
            }
        }
    }

    func fetchUserID() {
        if let user = Auth.auth().currentUser {
            userID = user.email ?? "No Email"
        }
    }

    func fetchBalance() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("Users").document(user.uid).getDocument { snapshot, error in
            if let error = error {
                print("残高の取得に失敗しました: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data(), let fetchedBalance = data["balance"] as? Double {
                self.balance = fetchedBalance
            } else {
                self.showInitialBalanceView = true
            }
        }
    }

    func fetchHistory() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("Users").document(user.uid).collection("History").getDocuments { snapshot, error in
            if let error = error {
                print("履歴の取得に失敗しました: \(error.localizedDescription)")
                return
            }
            self.history = snapshot?.documents.compactMap { doc in
                if let amount = doc["amount"] as? Double, let date = doc["date"] as? String {
                    return HistoryEntry(amount: amount, date: date)
                }
                return nil
            } ?? []
        }
    }
}
