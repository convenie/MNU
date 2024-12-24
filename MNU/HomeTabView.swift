import SwiftUI

struct HomeTabView: View {
    @Binding var balance: Double?
    @Binding var inputAmount: String
    @Binding var showUpdateAlert: Bool
    @Binding var showInitialBalanceView: Bool

    var body: some View {
        VStack {
            if let balance = balance {
                // 残高の表示
                Text("現在の残高\n\(balance, specifier: "%.0f")円")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: BalanceUpdateView(balance: $balance, inputAmount: $inputAmount, onSave: {
                    showUpdateAlert = true
                })) {
                    Text("残高追加・減少")
                }

                // 残高に応じた財布の中身を表示
                WalletView(balance: Int(balance))

            } else {
                Text("残高を取得中...")
                    .font(.headline)
                    .padding()
            }
        }
    }
}

struct WalletView: View {
    var balance: Int

    var body: some View {
        // balanceがマイナスなら赤、それ以外は灰色
        let isNegative = balance < 0

        VStack {
            Text("財布の中身")
                .font(.headline)
                .padding(.bottom, 5)

            ZStack {
                // 財布の背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(isNegative ? Color.red : Color.gray.opacity(0.2)) // balanceがマイナスなら赤、そうでないなら灰色
                    .frame(width: 300, height: 300)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 4)
                    )

                // スクロール可能な中身
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(calculateDenominations(for: abs(balance)), id: \.self) { denomination in
                            VStack(alignment: .leading) {

                                if denomination.count > 4 {
                                    // 5枚以上の場合、まとめて表示
                                    HStack {
                                        DenominationShape(value: denomination.value)
                                        Text("✖️\(denomination.count)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    // 4枚以下の場合、個別に表示
                                    HStack {
                                        ForEach(0..<denomination.count, id: \.self) { _ in
                                            DenominationShape(value: denomination.value)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(width: 280, height: 280) // スクロール領域を財布の中に限定
            }
        }
        .padding()
    }

    // 金種を計算する
    func calculateDenominations(for amount: Int) -> [Denomination] {
        let denominations: [(value: Int, label: String)] = [
            (10000, "10,000円紙幣"),
            (5000, "5,000円紙幣"),
            (1000, "1,000円紙幣"),
            (500, "500円硬貨"),
            (100, "100円硬貨"),
            (50, "50円硬貨"),
            (10, "10円硬貨"),
            (5, "5円硬貨"),
            (1, "1円硬貨")
        ]

        var remainingAmount = amount
        var result: [Denomination] = []

        for denom in denominations {
            let count = remainingAmount / denom.value
            remainingAmount %= denom.value

            if count > 0 {
                result.append(Denomination(label: denom.label, count: count, value: denom.value))
            }
        }

        return result
    }
}


// 金種の情報を保持する構造体
struct Denomination: Hashable {
    let label: String
    let count: Int
    let value: Int
}

struct DenominationShape: View {
    let value: Int

    var body: some View {
        Group {
            if value >= 1000 {
                // 紙幣の形状
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color(for: value))
                        .frame(width: 100, height: 50)
                        .overlay(
                            Text("\(value)円")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        )

                    // 画像を重ねる
                    Image("billImage") // 画像名を変更する
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 40) // 画像のサイズ調整
                }
            } else {
                // 硬貨の形状
                ZStack {
                    Circle()
                        .fill(color(for: value))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("\(value)円")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        )

                    // 画像を重ねる
                    Image("coin\(value)") // 例えば "coin1"、"coin5" などの画像名を使う
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60) // 画像のサイズ調整
                }
            }
        }
    }

    // 金種に応じた色
    func color(for value: Int) -> Color {
        switch value {
        case 10000: return Color(red: 1.0, green: 0.87, blue: 0.76) // 10,000円
        case 5000: return Color(red: 1.0, green: 0.67, blue: 0.62)  // 5,000円
        case 1000: return Color(red: 1.0, green: 0.37, blue: 0.37)  // 1,000円
        case 500: return Color(red: 1.0, green: 0.93, blue: 0.36)   // 500円
        case 100: return Color(red: 0.66, green: 0.83, blue: 0.95)  // 100円
        case 50: return Color(red: 0.97, green: 0.97, blue: 0.66)   // 50円
        case 10: return Color(red: 0.78, green: 0.94, blue: 0.7)    // 10円
        case 5: return Color(red: 0.71, green: 0.89, blue: 0.55)    // 5円
        case 1: return Color(red: 0.95, green: 0.79, blue: 0.94)    // 1円
        default: return Color.gray
        }
    }
}
