//
//  MainScreenTableViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 16.10.2022.
//

import Foundation
import RxDataSources
import RxSwift
import CoreData

// MARK: Sections for tableview
struct SectionOfTransactionModel {
    var header: String
    var items: [Item]
}
extension SectionOfTransactionModel: SectionModelType {
    typealias Item = Transaction
    
    init(original: SectionOfTransactionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

// MARK: Delegate
protocol MainScreenViewModelProtocol {
    var isSideMenuDisplayed: Bool { get set }
    var gesturePanBeginingPosition: CGFloat { get set }
    var sections: BehaviorSubject<[SectionOfTransactionModel]> { get }
    init(_ viewController: MainScreenViewControllerDelegate)
}

// MARK: ViewModel
class MainScreenViewModel: MainScreenViewModelProtocol {
    //sideMenu
    var isSideMenuDisplayed: Bool = false
    var gesturePanBeginingPosition: CGFloat = 500
    
    //tableView Sections
    var sections = BehaviorSubject<[SectionOfTransactionModel]>(value: [])
    
    unowned var viewController: MainScreenViewControllerDelegate!
    
    // MARK: Init
    required init(_ viewController: MainScreenViewControllerDelegate) {
        self.viewController = viewController
        getSections()
    }
    
    // MARK: GetSections Method
    private func getSections() {
        //        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        //        let transactions = (try? viewController.context.fetch(fetchRequest))!
        
        let transaction = Transaction(context: viewController.context)
        transaction.isIncome = true
        transaction.category = "Jopa"
        transaction.amount = "199 999.90"
        transaction.date = Date()
        transaction.isIncome = false
        
        sections.onNext([SectionOfTransactionModel(header: "21.09.2002", items: [transaction])])
    }
}
