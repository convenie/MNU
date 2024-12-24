//
//  HistoryEntry.swift
//  MoneyNotUse
//
//  Created by Yuri Mizui on 2024/12/15.
//


// Models/HistoryEntry.swift

import Foundation

// 履歴データのモデル
struct HistoryEntry: Identifiable {
    var id: String { "\(amount)-\(date)" }  // idは金額と日付を基に生成
    var amount: Double
    var date: String
}
