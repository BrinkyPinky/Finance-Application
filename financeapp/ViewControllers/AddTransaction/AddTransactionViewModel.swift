//
//  AddTransactionViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import Foundation

enum TransactionsTypes {
    case income, outcome
}

protocol AddTransactionViewModelProtocol {
    var currentTransactionType: TransactionsTypes { get set }
    var incomingCategories: [String] { get }
    var outcomingCategories: [String] { get }
    var numberOfItemsInSection: Int { get }
    func checkForDotsInAmountOfTransaction(_ text: inout String?)
    func formatAmounOfTransactionOnEditingEnd(_ text: String?) -> String
    func categoryNameForItem(at indexPath: IndexPath) -> String
    func formatDate(_ date: Date?) -> String
}

class AddTransactionViewModel: AddTransactionViewModelProtocol {
    var currentTransactionType: TransactionsTypes = .income
    
    var incomingCategories = [
        "💰 Зарплата",
        "🤑 Бонус",
        "📊 Инвестиции"
    ]
    var outcomingCategories = [
        "🥬 Продукты",
        "💳 Перевод",
        "🚗 Автомобиль",
        "💸 Ипотека",
        "💊 Лекарства",
    ]
    
    var numberOfItemsInSection: Int {
        switch currentTransactionType {
        case .income:
            return incomingCategories.count
        case .outcome:
            return outcomingCategories.count
        }
    }
    
    func categoryNameForItem(at indexPath: IndexPath) -> String {
        switch currentTransactionType {
        case .income:
            return incomingCategories[indexPath.row]
        case .outcome:
            return outcomingCategories[indexPath.row]
        }
    }
    
    func checkForDotsInAmountOfTransaction(_ text: inout String?) {
        guard text?.last == "." else { return }
        
        var dotsCounter = 0
        for char in text! {
            if char == "." {
                dotsCounter += 1
            }
        }
        if dotsCounter > 1 {
            text?.removeLast()
        }
    }
    
    //    func formatAmountOfTransaction(_ text: String?) -> String {
    //        guard var text else { return "" }
    //
    //        if text.last == "." {
    //            var dotsCounter = 0
    //            for char in text {
    //                if char == "." {
    //                    dotsCounter += 1
    //                }
    //            }
    //            if dotsCounter > 1 {
    //                text.removeLast()
    //            }
    //
    //            return text
    //        } else {
    //            var specifiedText = text
    //            specifiedText.removeAll(where: { $0 == " " })
    //            guard let number = Double(specifiedText) else { return text }
    //            let formatter = NumberFormatter()
    //            formatter.numberStyle = .decimal
    //            formatter.locale = Locale(identifier: "ru_RU")
    //            formatter.decimalSeparator = "."
    //            let formattedText = formatter.string(from: NSDecimalNumber(string: String(format: "%.02f", number)))
    //
    //            return formattedText ?? "0"
    //        }
    //    }
    
    func formatAmounOfTransactionOnEditingEnd(_ text: String?) -> String {
        guard let text else { return "Error" }
        guard let number = Double(text) else { return "Error" }
        
//        let formattedString = String(format: "%.02f", number)
        
//        guard let formattedNumber = Float()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        let formattedText = formatter.string(from: NSNumber(floatLiteral: number))
        
        return formattedText ?? "Error"
    }
    
    func formatDate(_ date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date ?? Date())
    }
}
