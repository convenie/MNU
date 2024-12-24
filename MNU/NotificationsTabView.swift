import SwiftUI
import FirebaseFirestore

// 通知データモデル
struct Notification: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var message: String
    var timestamp: Timestamp
}

struct NotificationsTabView: View {
    @State private var notifications: [Notification] = []
    @State private var isLoading: Bool = true
    @State private var selectedNotification: Notification? // 選択された通知
    
    private var db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Text("通知")
                .font(.title2)
                .foregroundColor(.blue)
                .padding()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                if notifications.isEmpty {
                    Text("ただいま新規の通知はありません。システムからのお知らせをお待ちください。")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // タイトルと日時のみ表示するリスト
                    List(notifications) { notification in
                        Button(action: {
                            selectedNotification = notification // 通知を選択
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(notification.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(" \(notification.timestamp.dateValue(), formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchNotifications()
        }
        // 選択した通知の詳細を表示するシート
        .sheet(item: $selectedNotification) { notification in
            NotificationDetailView(notification: notification)
        }
    }
    
    // Firestoreから通知データを取得
    private func fetchNotifications() {
        db.collection("notifications")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                isLoading = false
                if let error = error {
                    print("通知の取得中にエラーが発生しました: \(error.localizedDescription)")
                } else {
                    notifications = snapshot?.documents.compactMap { document in
                        try? document.data(as: Notification.self)
                    } ?? []
                }
            }
    }
}

// 通知詳細を表示するビュー
struct NotificationDetailView: View {
    let notification: Notification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(notification.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(notification.message)
                .font(.body)
            
            Text(" \(notification.timestamp.dateValue(), formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
