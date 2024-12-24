//
//  AdminContactView.swift
//  MoneyNotUse
//
//  Created by Yuri Mizui on 2024/12/21.
//


import SwiftUI
import FirebaseFirestore

struct AdminContactView: View {
    @State private var contacts: [Contact] = []
    
    var body: some View {
        List(contacts) { contact in
            VStack(alignment: .leading) {
                Text("名前: \(contact.name)")
                    .font(.headline)
                Text("メール: \(contact.email)")
                    .font(.subheadline)
                Text("内容: \(contact.message)")
                    .font(.body)
                Text("送信日時: \(contact.timestamp, formatter: DateFormatter.shortDate)")
                    .font(.footnote)
                Text("状態: \(contact.status)")
                    .foregroundColor(contact.status == "未対応" ? .red : .green)
                    .font(.subheadline)
            }
            .padding()
        }
        .onAppear {
            fetchContacts()
        }
    }
    
    func fetchContacts() {
        let db = Firestore.firestore()
        db.collection("contacts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("データの取得に失敗しました: \(error.localizedDescription)")
                    return
                }
                
                self.contacts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Contact.self)
                } ?? []
            }
    }
}

struct AdminContactView_Previews: PreviewProvider {
    static var previews: some View {
        AdminContactView()
    }
}

struct Contact: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var message: String
    var timestamp: Timestamp
    var status: String
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
