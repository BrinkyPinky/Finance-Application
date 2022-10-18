//
//  FormatValueManager.swift
//  financeapp
//
//  Created by Егор Шилов on 18.10.2022.
//

import Foundation

class FormatValueManager {
    static let shared = FormatValueManager()
    
    func formatToDecimalNumber(_ number: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(floatLiteral: number))
    }
    
    func formateDate(_ date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
