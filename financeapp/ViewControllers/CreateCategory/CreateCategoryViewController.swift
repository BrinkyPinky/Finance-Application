//
//  CreateCategoryViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit
import RxSwift
import RxDataSources
import CoreData

protocol CreateCategoryViewControllerDelegate: AnyObject {
    var context: NSManagedObjectContext { get }
    func showAlert(isTextFieldNeeded: Bool, title: String, message: String)
}

class CreateCategoryViewController: UIViewController, CreateCategoryViewControllerDelegate {
    private var viewModel: CreateCategoryViewModelProtocol!
    
    @IBOutlet private var incomeButton: UIBarButtonItem!
    @IBOutlet private var outcomeButton: UIBarButtonItem!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var editButton: UIBarButtonItem!
    
    @IBOutlet private var viewBackgroundAddButton: UIView!
    @IBOutlet private var addButton: UIButton!
    
    @IBOutlet private var viewBackgroundCustomAlert: UIView!
    
    var context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    
    private let dataSource = RxTableViewSectionedReloadDataSource<SectionOfTransactionCategoryModel> { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(item.name ?? "NO NAME")"
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
        viewModel = CreateCategoryViewModel(self)
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        viewBackgroundAddButton.layer.cornerRadius = viewBackgroundAddButton.frame.width / 2
        
        //observe elements in table view
        viewModel.sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        //item interaction
        tableView.rx.itemDeleted.subscribe { [unowned self] indexPath in
            viewModel.deleteCategory(at: indexPath.element)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemMoved.subscribe { [unowned self] event in
            viewModel.moveCategory(
                source: event.element?.sourceIndex,
                destination: event.element?.destinationIndex
            )
        }.disposed(by: disposeBag)
        
        //edit button action
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
        incomeButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.incomeButton.tintColor = .systemGreen
            self.outcomeButton.tintColor = .secondaryLabel
            self.viewModel.isCurrentTypeIncome = true
        }.disposed(by: disposeBag)
        
        outcomeButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.outcomeButton.tintColor = .systemGreen
            self.incomeButton.tintColor = .secondaryLabel
            self.viewModel.isCurrentTypeIncome = false
        }.disposed(by: disposeBag)
        
        addButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.showAlert(
                isTextFieldNeeded: true,
                title: "Новая категория",
                message: "Введите имя новой категории"
            )
        }.disposed(by: disposeBag)
    }
    
    // MARK: Show Alert which add new category
    
    func showAlert(isTextFieldNeeded: Bool, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard isTextFieldNeeded else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            return
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] action in
            let textfield = alert.textFields![0]
            viewModel.appendNewCategory(name: textfield.text)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive))
        alert.addTextField() { textField in
            textField.placeholder = "Налоги"
        }
        self.present(alert, animated: true)
    }
}
