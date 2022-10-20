//
//  CreateCategoryViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import Foundation
import RxDataSources
import RxSwift
import CoreData

struct SectionOfCategoryModel {
    var header: String
    var items: [Item]
}

extension SectionOfCategoryModel: SectionModelType {
    typealias Item = Categories

    var identity: String {
        return header
    }

    init(original: SectionOfCategoryModel, items: [Item]) {
        self = original
        self.items = items
    }
}

//protocol for ViewController
protocol CreateCategoryViewModelProtocol {
    var sections: BehaviorSubject<[SectionOfCategoryModel]> { get }
    var isCurrentTypeIncome: Bool { get set }
    init(_ viewController: CreateCategoryViewControllerDelegate)
    func appendNewCategory(name: String?)
    func deleteCategory(at indexPath: IndexPath?)
    func moveCategory(source: IndexPath?, destination: IndexPath?)
}

class CreateCategoryViewModel: CreateCategoryViewModelProtocol {
    var isCurrentTypeIncome = true {
        didSet {
            getSections()
        }
    }
    
    var sections = BehaviorSubject<[SectionOfCategoryModel]>(value: [])
    
    unowned var viewController: CreateCategoryViewControllerDelegate!
            
    // MARK: Init
    required init(_ viewController: CreateCategoryViewControllerDelegate) {
        self.viewController = viewController
        getSections()
    }
    
    // MARK: Get Sections
    private func getSections() {
        let fetchRequest: NSFetchRequest<Categories> = Categories.fetchRequest()
        let hederTitle = isCurrentTypeIncome ? "Приход" : "Расход"
        
        do {
            sections.onNext([
                SectionOfCategoryModel(
                    header: hederTitle,
                    items: try viewController.context.fetch(fetchRequest)
                        .filter({ $0.isIncome == isCurrentTypeIncome })
                        .sorted(by: { $0.orderID < $1.orderID })
                )
            ])
        } catch {
            print("error occured with getting categories")
            sections.onNext([SectionOfCategoryModel(
                header: hederTitle,
                items: [])])
        }
    }
    
    // MARK: User Interactions
    
    func appendNewCategory(name: String?) {
        guard let name, name != "" else { return }
        guard var sections = try? sections.value() else { return }
        
        guard sections[0].items.count < 50 else {
            viewController.showCustomAlert()
            return
        }
        
        let category = Categories(context: viewController.context)
        category.name = name
        category.isIncome = isCurrentTypeIncome
        category.orderID = (sections[0].items.last?.orderID ?? 0) + 1
        sections[0].items.append(category)
        self.sections.onNext(sections)
        
        saveCoreDataObject()
        self.sections.onNext(sections)
    }
    
    func deleteCategory(at indexPath: IndexPath?) {
        guard let indexPath else { return }
        guard var sections = try? sections.value() else { return }
        let category = sections[0].items.remove(at: indexPath.row)
        viewController.context.delete(category)
        saveCoreDataObject()
        self.sections.onNext(sections)
    }
    
    func moveCategory(source: IndexPath?, destination: IndexPath?) {
        guard let sections = try? sections.value(), let source, let destination else { return }
        
        if source.row > destination.row {
            sections[0].items[source.row].orderID = sections[0].items[destination.row].orderID - 1
            for i in destination.row...sections[0].items.count - 1 {
                sections[0].items[i].orderID += 1
            }
        } else if source.row < destination.row {
            sections[0].items[source.row].orderID = sections[0].items[destination.row].orderID + 1
            for i in 0...destination.row {
                sections[0].items[i].orderID -= 1
            }
        }
        
        saveCoreDataObject()
        getSections()
    }
    
    // MARK: Save Changes to CoreData
    
    private func saveCoreDataObject() {
        if viewController.context.hasChanges {
            do {
                try viewController.context.save()
            } catch let error {
                print(error)
            }
        }
    }
}
