//
//  CreateCategoryViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import Foundation
import RxDataSources
import RxSwift

struct SectionOfTransactionCategoryModel {
    var header: String
    var items: [Item]
}

extension SectionOfTransactionCategoryModel: SectionModelType {
    typealias Item = TransactionCategoryModel
    
    init(original: SectionOfTransactionCategoryModel, items: [Item]) {
        self = original
        self.items = items
    }
}

protocol CreateCategoryViewModelProtocol {
    var sections: BehaviorSubject<[SectionOfTransactionCategoryModel]> { get }
    var isCurrentTypeIncome: Bool { get set }
    func appendNewCategory(name: String?)
}

class CreateCategoryViewModel: CreateCategoryViewModelProtocol {
    var isCurrentTypeIncome = true {
        didSet {
            getSections()
        }
    }
    
    var sections = BehaviorSubject<[SectionOfTransactionCategoryModel]>(value: [])
    
    private func getSections() {
        sections.onNext([SectionOfTransactionCategoryModel(
            header: isCurrentTypeIncome ? "Приход" : "Расход",
            items: CategoriesDataManager.shared.getCategories(isIncome: isCurrentTypeIncome)
        )])
    }
    
    func appendNewCategory(name: String?) {
        guard let name else { return }
    }
}
