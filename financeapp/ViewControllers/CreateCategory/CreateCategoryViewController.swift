//
//  CreateCategoryViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

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

class CreateCategoryViewController: UIViewController {
    
    private var viewModel: CreateCategoryViewModelProtocol!
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var editButton: UIBarButtonItem!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfTransactionCategoryModel> { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(item.name)"
        return cell
    } titleForHeaderInSection: { dataSource, index in
        return dataSource.sectionModels[index].header
    } canEditRowAtIndexPath: { dataSource, indexPath in
        return true
    } canMoveRowAtIndexPath: { dataSource, indexPath in
        return true
    }
    
    private let sections = [
        SectionOfTransactionCategoryModel(header: "Приход", items: [
            TransactionCategoryModel(id: 1, name: "Зарплата", isIncome: true),
            TransactionCategoryModel(id: 2, name: "Бонус", isIncome: true),
            TransactionCategoryModel(id: 3, name: "Перевод", isIncome: true)
        ])
    ]
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CreateCategoryViewModel()
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        //observe elements
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        //item interaction
        tableView.rx.itemDeleted.subscribe { indexPath in
            print(indexPath)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemMoved.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
        
        //edit button
        editButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            guard self.tableView.isEditing else {
                self.editButton.title = "Done"
                self.tableView.setEditing(true, animated: true)
                return
            }
            self.editButton.title = "Edit"
            self.tableView.setEditing(false, animated: true)
        }.disposed(by: disposeBag)
    }
}
