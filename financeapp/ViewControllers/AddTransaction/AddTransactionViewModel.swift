//
//  AddTransactionViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import CoreData

enum TransactionsTypes {
    case income, outcome
}

protocol AddTransactionViewModelProtocol {
    var currentTransactionType: TransactionsTypes { get set }
    var incomingCategories: [Categories] { get }
    var outcomingCategories: [Categories] { get }
    init(viewController: AddTransactionViewControllerDelegate)
    func checkForDotsInAmountOfTransaction(_ text: inout String?)
    func formatAmountOfTransactionOnEditingEnd(_ text: String?) -> String
    func categoryNameForItem(at indexPath: IndexPath) -> String
    func numberOfItemsInSection() -> Int
    func formatDate(_ date: Date?) -> String
}

class AddTransactionViewModel: AddTransactionViewModelProtocol {
    unowned var viewController: AddTransactionViewControllerDelegate!
    
    var currentTransactionType: TransactionsTypes = .income

    // MARK: Categories
    
    var incomingCategories: [Categories] = []
    
    var outcomingCategories: [Categories] = []
    
    
    required init(viewController: AddTransactionViewControllerDelegate) {
        self.viewController = viewController
        let fetchRequest = NSFetchRequest<Categories>(entityName: "Categories")
        
        incomingCategories = try! viewController.context.fetch(fetchRequest)
            .filter({ $0.isIncome == true })
            .sorted(by: { $0.orderID < $1.orderID })
        
        outcomingCategories = try! viewController.context.fetch(fetchRequest)
            .filter({ $0.isIncome == false })
            .sorted(by: { $0.orderID < $1.orderID })
    }
    
    // MARK: Categories collection view gets the data

    func numberOfItemsInSection() -> Int {
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
            return incomingCategories[indexPath.row].name!
        case .outcome:
            return outcomingCategories[indexPath.row].name!
        }
    }
    
    // MARK: Checks AmountOfTransaction TextField for additional dots and deletes it if necessary
    
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
    
    // MARK: Format AmountOfTransaction TextField when editingDidEnd
    
    func formatAmountOfTransactionOnEditingEnd(_ text: String?) -> String {
        guard let text else { return "Error" }
        guard let number = Double(text) else { return "Error" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let formattedText = formatter.string(from: NSNumber(floatLiteral: number))
        
        return formattedText ?? "Error"
    }
    
    // MARK: DatePicker Formatter
    
    func formatDate(_ date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date ?? Date())
    }
}
