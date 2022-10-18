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
    init(_ viewController: MainScreenViewControllerContextDelegate)
    func getSections()
}

// MARK: ViewModel
class MainScreenViewModel: MainScreenViewModelProtocol {
    //sideMenu
    var isSideMenuDisplayed: Bool = false
    var gesturePanBeginingPosition: CGFloat = 500
    
    //tableView Sections
    var sections = BehaviorSubject<[SectionOfTransactionModel]>(value: [])
    
    unowned var viewController: MainScreenViewControllerContextDelegate!
    
    // MARK: Init
    required init(_ viewController: MainScreenViewControllerContextDelegate) {
        self.viewController = viewController
        getSections()
    }
    
    // MARK: GetSections Method
    func getSections() {
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 20
        let transactions = try? viewController.context.fetch(fetchRequest)
        
        guard let transactions else { return }
        var referenceDate: String?
        var sections: [SectionOfTransactionModel] = []
        var firstLevelSection: SectionOfTransactionModel?
        
        for transaction in transactions {
            let dateForReference = FormatValueManager.shared
                .formateDate(transaction.date!, dateStyle: .short, timeStyle: .none)
            let dateForHeader = FormatValueManager.shared
                .formateDate(transaction.date!, dateStyle: .long, timeStyle: .none)

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
        }
        sections.append(firstLevelSection!)
        
        self.sections.onNext(sections)
    }
}
