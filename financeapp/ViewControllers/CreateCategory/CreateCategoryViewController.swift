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
    func showCustomAlert()
}

class CreateCategoryViewController: UIViewController, CreateCategoryViewControllerDelegate {
    private var viewModel: CreateCategoryViewModelProtocol!
    
    //Navigation Items
    @IBOutlet private var incomeButton: UIBarButtonItem!
    @IBOutlet private var outcomeButton: UIBarButtonItem!
    @IBOutlet private var editButton: UIBarButtonItem!
    
    //table view
    @IBOutlet private var tableView: UITableView!
    
    //Button to add new category
    @IBOutlet private var viewBackgroundAddButton: UIView!
    @IBOutlet private var addButton: UIButton!
    
    //custom alert
    @IBOutlet private var viewBackgroundCustomAlert: UIView!
    
    //CoreData context
    var context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    
    //table view dataSource
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
        
        viewBackgroundAddButton.layer.cornerRadius = 20
        
        //custom alert
        viewBackgroundCustomAlert.translatesAutoresizingMaskIntoConstraints = true
        viewBackgroundCustomAlert.layer.cornerRadius = viewBackgroundCustomAlert.layer.frame.height / 2
        viewBackgroundCustomAlert.layer.position = CGPoint(
            x: viewBackgroundCustomAlert.layer.position.x,
            y: view.frame.height + viewBackgroundCustomAlert.frame.height
        )
        
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
                title: "Новая категория",
                message: "Введите имя новой категории"
            )
        }.disposed(by: disposeBag)
    }
    
    // MARK: Show Alerts
    
    //standart with textfield
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    
    //custom w/ error occured with adding more than 50 categories
    func showCustomAlert() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut]) {
                self.viewBackgroundCustomAlert.layer.position = CGPoint(
                    x: self.viewBackgroundCustomAlert.layer.position.x,
                    y: self.view.frame.height / 1.1
                )
            } completion: { _ in
                UIView.animate(
                    withDuration: 0.6,
                    delay: 3,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: [.curveEaseInOut]) {
                        self.viewBackgroundCustomAlert.layer.position = CGPoint(
                            x: self.viewBackgroundCustomAlert.layer.position.x,
                            y: self.view.frame.height + self.viewBackgroundCustomAlert.frame.height
                        )
                    }
            }
        
    }
}
