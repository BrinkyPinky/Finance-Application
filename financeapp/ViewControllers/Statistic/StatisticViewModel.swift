//
//  StatisticViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 19.10.2022.
//

import Foundation
import CoreData
import RxDataSources
import RxSwift

//rxDataSource Section Object
struct SectionOfStatisticModel {
    var header: String
    var items: [Item]
}

extension SectionOfStatisticModel: SectionModelType {
    typealias Item = StatisticModel

    var identity: String {
        return header
    }

    init(original: SectionOfStatisticModel, items: [Item]) {
        self = original
        self.items = items
    }
}

//ViewModel
protocol StatisticViewModelProtocol {
    var sections: BehaviorSubject<[SectionOfStatisticModel]> { get }
    init(_ viewController: StatisticViewControllerDelegate)
    func getInformation()
}

class StatisticViewModel: StatisticViewModelProtocol {
    private unowned var viewController: StatisticViewControllerDelegate!
    
    var sections = BehaviorSubject(value: [SectionOfStatisticModel]())
    
    // MARK: Init
    required init(_ viewController: StatisticViewControllerDelegate) {
        self.viewController = viewController
    }
    
    // MARK: Get All Information
    func getInformation() {
        let predicate = NSPredicate(
            format: "(date >= %@) AND (date <= %@)",
            Date().addingTimeInterval(-2592000) as CVarArg,
            Date() as CVarArg
        )
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.predicate = predicate
        let elements = try? viewController.context.fetch(fetchRequest)
        guard let elements else { return }
        
        var profitSummary: Double = 0
        var expenditureSummary: Double = 0
        var categorySummary = [String:Double]()
        for i in elements {
            if i.isIncome {
                profitSummary += i.amount
            } else {
                expenditureSummary += i.amount
                if categorySummary.contains(where: { $0.key == i.category }) {
                    categorySummary[i.category]! += i.amount
                } else {
                    categorySummary[i.category] = i.amount
                }
            }
        }
        viewController.updateProfitLabel(
            "\(FormatValueManager.shared.formatToDecimalNumber(profitSummary) ?? "Нет информации") ₽"
        )
        viewController.updateExpenditureLabel(
            "\(FormatValueManager.shared.formatToDecimalNumber(expenditureSummary) ?? "Нет информации") ₽"
        )
        
        var statisticsModels = [StatisticModel]()
        categorySummary.forEach { (key: String, value: Double) in
            let statisticModel = StatisticModel(
                percent: Int(((value / expenditureSummary) * 100).rounded(.towardZero)),
                amount: FormatValueManager.shared.formatToDecimalNumber(value) ?? "Нет информации",
                categoryName: key
            )
            statisticsModels.append(statisticModel)
        }
        sections.onNext([SectionOfStatisticModel(header: "Траты по категориям", items: statisticsModels)])
    }
}
