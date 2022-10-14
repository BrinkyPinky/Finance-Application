//
//  CreateCategoryViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit
import RxSwift
import RxDataSources

class CreateCategoryViewController: UIViewController {
    
    private var viewModel: CreateCategoryViewModelProtocol!
    
    @IBOutlet var incomeButton: UIBarButtonItem!
    @IBOutlet var outcomeButton: UIBarButtonItem!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var editButton: UIBarButtonItem!
    
    @IBOutlet var viewBackgroundAddButton: UIView!
    @IBOutlet var addButton: UIButton!
    
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
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CreateCategoryViewModel()
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        viewBackgroundAddButton.layer.cornerRadius = viewBackgroundAddButton.frame.width / 2
        
        //observe elements
        viewModel.sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
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
        
        //button Actions
        incomeButton.rx.tap.subscribe { [unowned self] _ in
            incomeButton.tintColor = .systemGreen
            outcomeButton.tintColor = .secondaryLabel
            viewModel.isCurrentTypeIncome = true
        }.disposed(by: disposeBag)
        
        outcomeButton.rx.tap.subscribe { [unowned self] _ in
            outcomeButton.tintColor = .systemGreen
            incomeButton.tintColor = .secondaryLabel
            viewModel.isCurrentTypeIncome = false
        }.disposed(by: disposeBag)
        
        addButton.rx.tap.subscribe { [unowned self] _ in
            showAlert()
        }.disposed(by: disposeBag)
    }
    
    // MARK: Show Alert which add new category
    
    private func showAlert() {
        let alert = UIAlertController(title: "Новая категория", message: "Введите имя новой категории", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] action in
            let textfield = alert.textFields![0]
            viewModel.appendNewCategory(name: textfield.text)
        })
        alert.addTextField() { textField in
            textField.placeholder = "Налоги"
        }
        self.present(alert, animated: true)
    }
}
