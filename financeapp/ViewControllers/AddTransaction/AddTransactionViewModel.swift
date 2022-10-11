//
//  AddTransactionViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import Foundation

protocol AddTransactionViewModelProtocol {
    var incomingCategories: [String] { get }
    var outcomingCategories: [String] { get }
}

class AddTransactionViewModel: AddTransactionViewModelProtocol {
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
}
