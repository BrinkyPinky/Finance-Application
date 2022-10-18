//
//  AddTransactionViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import CoreData


protocol AddTransactionViewModelProtocol {
    var isIncome: Bool { get set }
    var incomingCategories: [Categories] { get }
    var outcomingCategories: [Categories] { get }
    init(viewController: AddTransactionViewControllerDelegate)
    func checkForDotsInAmountOfTransaction(_ text: inout String?)
    func formatAmountOfTransactionOnEditingEnd(_ text: String?) -> String
    func categoryNameForItem(at indexPath: IndexPath) -> String
    func numberOfItemsInSection() -> Int
    func formatDate(_ date: Date?) -> String
    func saveTransaction(amount: String?, date: Date, categoryIndexPath: IndexPath?, comment: String?, errorMessage: (String) -> Void, completion: () -> Void)
}

class AddTransactionViewModel: AddTransactionViewModelProtocol {
    unowned var viewController: AddTransactionViewControllerDelegate!
    
    var isIncome = true
    
    //List of categories
    var incomingCategories: [Categories] = []
    var outcomingCategories: [Categories] = []
    
    // MARK: Init
    
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
        isIncome ? incomingCategories.count : outcomingCategories.count
    }
    
    func categoryNameForItem(at indexPath: IndexPath) -> String {
        isIncome ? incomingCategories[indexPath.row].name! : outcomingCategories[indexPath.row].name!
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
        let formattedText = FormatValueManager.shared.formatToDecimalNumber(number)
        return formattedText ?? "Error"
    }
    
    // MARK: DatePicker Formatter
    
    func formatDate(_ date: Date?) -> String {
        return FormatValueManager.shared.formateDate(
            date ?? Date(),
            dateStyle: .long,
            timeStyle: .short
        )
    }
    
    // MARK: Save Transaction
    
    func saveTransaction(
        amount: String?,
        date: Date,
        categoryIndexPath: IndexPath?,
        comment: String?,
        errorMessage: (String) -> Void,
        completion: () -> Void
    ) {
        //amount check
        guard var amount else {
            errorMessage("Сумма имеет неверный формат")
            return
        }
        amount.removeAll(where: { $0 == " " })
        guard let amount = Double(amount) else {
            errorMessage("Сумма имеет неверный формат")
            return
        }
        //category check
        guard let categoryIndexPath else {
            errorMessage("Никакая категория не выбрана")
            return
        }
        let categoryName = categoryNameForItem(at: categoryIndexPath)
        
        let transaction = Transaction(context: viewController.context)
        transaction.amount = amount
        transaction.date = date
        transaction.category = categoryName
        transaction.isIncome = isIncome
        transaction.comment = comment ?? ""
        
        do {
            try viewController.context.save()
            completion()
        } catch {
            errorMessage("Что-то пошло не так.\nНе удается сохранить ваши данные")
        }
    }
}
