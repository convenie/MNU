import SwiftUI

struct CalendarTabView: View {
    @State private var selectedDate = Date()  // 選択された日付
    @State private var currentDate = Date()   // 表示中の年月

    var body: some View {
        VStack {
            // ヘッダー部分：<<, 年月, >>
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))  // フォントサイズを小さく調整
                        .padding(5)  // ボタンの余白を減らす
                }
                Spacer()
                Text(currentMonthAndYear)
                    .font(.title)
                    .bold()
                    .padding(.horizontal, 8)  // 左右の余白を追加
                Spacer()
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))  // フォントサイズを小さく調整
                        .padding(5)  // ボタンの余白を減らす
                }
            }
            .padding()


            // 曜日と日付を統一した表デザイン
            VStack(spacing: 0) {
                // 曜日のヘッダー部分
                weekdayHeader

                // カレンダーの日付グリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(datesForCurrentMonth, id: \.self) { date in
                        dayCell(for: date)
                    }
                }
            }
            .padding()

            Spacer()
        }
        .onAppear {
            print("デバッグ: 表示中の年月: \(currentMonthAndYear)")
            print("デバッグ: 日付配列: \(datesForCurrentMonth)")
        }
    }

    // 曜日の配列 (日本語)
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .foregroundColor(weekday == "日" ? .red : weekday == "土" ? .blue : .primary)
            }
        }
    }

    // 日付セル
    private func dayCell(for date: Date) -> some View {
        let isCurrentMonth = calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
        
        return Text("\(calendar.component(.day, from: date))") // 日付を表示
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(isSameDay(date, selectedDate) ? Color.blue : isSameDay(date, Date()) ? Color.red.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .foregroundColor(isCurrentMonth ? (isSameDay(date, selectedDate) ? .white : isSameDay(date, Date()) ? .red : .primary) : Color.gray.opacity(0.5)) // 薄く表示
            .onTapGesture {
                if isCurrentMonth { // 選択可能なのは当月の日付のみ
                    print("デバッグ: 選択された日付: \(formattedDate(date))")
                    selectedDate = date
                }
            }
    }

    // 現在の年月 (日本語)
    private var currentMonthAndYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "y年M月"
        return formatter.string(from: currentDate)
    }

    // 表示中の月の日付の配列
    private var datesForCurrentMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }

        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end

        // 当月の開始曜日
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1

        var dates = [Date]()
        var currentDate = startOfMonth

        // 前月の日付で埋める
        if firstWeekday > 0 {
            for offset in (1...firstWeekday).reversed() {
                if let previousDay = calendar.date(byAdding: .day, value: -offset, to: startOfMonth) {
                    dates.append(previousDay)
                }
            }
        }

        // 当月の日付を追加
        while currentDate < endOfMonth {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            }
        }

        // 次月の日付で埋める
        let remainingDays = 7 - (dates.count % 7)
        if remainingDays < 7 {
            for offset in 0..<remainingDays {
                if let nextDay = calendar.date(byAdding: .day, value: offset, to: endOfMonth) {
                    dates.append(nextDay)
                }
            }
        }

        return dates
    }

    // 曜日の配列
    private var weekdays: [String] {
        ["日", "月", "火", "水", "木", "金", "土"] // 漢字で表示
    }

    // 日付フォーマット
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // 同じ日かどうかを判定
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    // 月の移動
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
            print("デバッグ: 新しい表示中の年月: \(currentMonthAndYear)")
        }
    }

    // カレンダーインスタンス
    private var calendar: Calendar {
        Calendar.current
    }
}
