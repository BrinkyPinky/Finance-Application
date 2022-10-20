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
import SwiftUICharts

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
        //getting TransactionModel from coredata
        let predicate = NSPredicate(
            format: "(date >= %@) AND (date <= %@)",
            Date().addingTimeInterval(-2592000) as CVarArg,
            Date() as CVarArg
        )
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.predicate = predicate
        let elements = try? viewController.context.fetch(fetchRequest)
        guard let elements else { return }
        
        //getting data to present
        var profitSummary: Double = 0
        var expenditureSummary: Double = 0
        var categorySummary = [String:Double]()
        var sevenDaysSpendSummary = [(String,Double)]()
        
        for i in 0...6 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            sevenDaysSpendSummary.append((
                dateFormatter.string(from: Date().addingTimeInterval(TimeInterval((-86400) * i))),
                0
            ))
        }
        sevenDaysSpendSummary.reverse()
        
        for element in elements {
            if element.isIncome {
                profitSummary += element.amount
            } else {
                expenditureSummary += element.amount
                if categorySummary.contains(where: { $0.key == element.category }) {
                    categorySummary[element.category]! += element.amount
                } else {
                    categorySummary[element.category] = element.amount
                }
                
                //sevenDaysSummary
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                let dateFormatted = dateFormatter.string(from: element.date)
                
                if let index = sevenDaysSpendSummary.firstIndex(where: { $0.0 == dateFormatted }) {
                    let oldElement = sevenDaysSpendSummary.remove(at: index)
                    sevenDaysSpendSummary.insert(
                        (oldElement.0, oldElement.1 + element.amount),
                        at: index
                    )
                }
            }
        }
                
        //present data
        viewController.setProfitLabel(
            "\(FormatValueManager.shared.formatToDecimalNumber(profitSummary) ?? "Нет информации") ₽"
        )
        viewController.setExpenditureLabel(
            "\(FormatValueManager.shared.formatToDecimalNumber(expenditureSummary) ?? "Нет информации") ₽"
        )
        viewController.setChartView(ChartData(values: sevenDaysSpendSummary))
                
        var statisticsModels = [StatisticModel]()
        categorySummary.forEach { (key: String, value: Double) in
            let statisticModel = StatisticModel(
                percent: Int(((value / expenditureSummary) * 100).rounded(.towardZero)),
                amount: FormatValueManager.shared.formatToDecimalNumber(value) ?? "Нет информации",
                categoryName: key
            )
            statisticsModels.append(statisticModel)
        }
        
        guard !statisticsModels.isEmpty else { return }
        sections.onNext([SectionOfStatisticModel(header: "Траты по категориям", items: statisticsModels)])
    }
}
