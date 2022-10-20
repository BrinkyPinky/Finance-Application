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
    func getSections(needToUpLimit: Bool)
    func deleteItem(at indexPath: IndexPath)
}

// MARK: ViewModel
class MainScreenViewModel: MainScreenViewModelProtocol {
    //sideMenu
    var isSideMenuDisplayed: Bool = false
    var gesturePanBeginingPosition: CGFloat = 500
    
    //tableView Sections
    var sections = BehaviorSubject<[SectionOfTransactionModel]>(value: [])
    
    //fetching Transactions
    private var fetchLimit = 20
    private var isPaginating = false
    
    unowned var viewController: MainScreenViewControllerDelegate!
    
    // MARK: Init
    required init(_ viewController: MainScreenViewControllerDelegate) {
        self.viewController = viewController
        getSections(needToUpLimit: false)
    }
    
    // MARK: GetSections Method
    func getSections(needToUpLimit: Bool) {
        guard !isPaginating else { return }
        isPaginating = true
        if needToUpLimit {
            fetchLimit += 20
        }
        
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = fetchLimit
        let transactions = try? viewController.context.fetch(fetchRequest)
        
        guard let transactions else { return }
        var referenceDate: String?
        var sections: [SectionOfTransactionModel] = []
        var firstLevelSection: SectionOfTransactionModel?
        
        for transaction in transactions {
            let dateForReference = FormatValueManager.shared
                .formateDate(transaction.date, dateStyle: .short, timeStyle: .none)
            let dateForHeader = FormatValueManager.shared
                .formateDate(transaction.date, dateStyle: .long, timeStyle: .none)
            
            if referenceDate == nil {
                referenceDate = dateForReference
                firstLevelSection = SectionOfTransactionModel(header: dateForHeader, items: [])
            }
            
            if dateForReference == referenceDate {
                firstLevelSection?.items.append(transaction)
            } else {
                referenceDate = dateForReference
                sections.append(firstLevelSection!)
                firstLevelSection = SectionOfTransactionModel(header: dateForHeader, items: [])
                firstLevelSection?.items.append(transaction)
            }
            viewController.updateAmountOfMoney(
                amount: "\(FormatValueManager.shared.formatToDecimalNumber(AmountOfMoneyDataManager.shared.getValue())!) ₽"
            )
        }
        
        guard let firstLevelSection else { return }
        sections.append(firstLevelSection)
        
        self.sections.onNext(sections)
        isPaginating = false
    }
    
    // MARK: Delete Item
    
    func deleteItem(at indexPath: IndexPath) {
        guard var sections = try? sections.value() else { return }
        let transactionToDelete = sections[indexPath.section].items.remove(at: indexPath.row)
        if sections[indexPath.section].items.count == 0 {
            sections.remove(at: indexPath.section)
        }
        
        AmountOfMoneyDataManager.shared.changeValue(
            transactionToDelete.amount,
            isNeedToIncrease: !transactionToDelete.isIncome
        )
        viewController.updateAmountOfMoney(
            amount: "\(FormatValueManager.shared.formatToDecimalNumber(AmountOfMoneyDataManager.shared.getValue())!) ₽"
        )
        
        viewController.context.delete(transactionToDelete)
        saveCoreDataObjects()
        self.sections.onNext(sections)
    }
    
    // MARK: Saving Any Changes to CoreData
    
    private func saveCoreDataObjects() {
        if viewController.context.hasChanges {
            do {
                try viewController.context.save()
            } catch {
                print("Не удалось сохранить изменения в CoreData")
            }
        }
    }
}
