//
//  MainScreenTableViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import RxDataSources
import CoreData

//context delegate
protocol MainScreenViewControllerDelegate: AnyObject {
    var context: NSManagedObjectContext { get }
    func updateAmountOfMoney(amount: String)
}

//transaction didchange delegate
protocol MainScreenViewControllerTransactionUpdateDelegate: AnyObject {
    func newTransactionAdded()
}

class MainScreenViewController: UIViewController, MainScreenViewControllerDelegate, MainScreenViewControllerTransactionUpdateDelegate {
    private var viewModel: MainScreenViewModelProtocol!
    
    @IBOutlet private var tableView: UITableView!
    private var sideMenuView: SideMenuView!
    @IBOutlet var amountOfMoneyLabel: UILabel!
    
    //coreData Context
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //disposeBag
    private let disposeBag = DisposeBag()
    
    //tableView DataSource
    private let dataSource = RxTableViewSectionedReloadDataSource<SectionOfTransactionModel> { dataSource, tableView, indexPath, item in
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCellRepresentable
        cell.transactionModel = item
        return cell as! UITableViewCell
    } titleForHeaderInSection: { dataSource, index in
        dataSource.sectionModels[index].header
    } canEditRowAtIndexPath: { _, _ in
        true
    }
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        setup()
    }
    
    // MARK: Side Menu Button Tapped Action
    @IBAction private func sideMenuButtonTapped(_ sender: Any) {
        moveSideMenu(isDisplayed: viewModel.isSideMenuDisplayed)
    }
    
    @IBAction private func addButtonTapped(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let addTransactionViewController = storyBoard
            .instantiateViewController(withIdentifier: "AddTransactionViewController") as! AddTransactionViewController
        addTransactionViewController.mainScreenDelegate = self
        present(addTransactionViewController, animated: true)
    }
    // MARK: Show or Hide Side Menu Method
    func moveSideMenu(isDisplayed: Bool) {
        guard !isDisplayed else {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 50,
                initialSpringVelocity: 0,
                options: .curveEaseInOut) {
                    self.sideMenuView.frame.origin.x = -self.view.frame.width/1.5
                }
            viewModel.isSideMenuDisplayed = false
            return
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 50,
            initialSpringVelocity: 0,
            options: .curveEaseInOut) {
                self.sideMenuView.frame.origin.x = 0
            }
        viewModel.isSideMenuDisplayed = true
    }
    
    // MARK: TransactionList DidChange
    func newTransactionAdded() {
        viewModel.getSections()
    }
    
    // MARK: Update Amount Of Money
    func updateAmountOfMoney(amount: String) {
        amountOfMoneyLabel.text = amount
    }
}

// MARK: Setup

extension MainScreenViewController {
    func setup() {
        viewModel = MainScreenViewModel(self)
        
        //tableView
        viewModel.sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        tableView.rx.rowHeight.onNext(85)
        tableView.rx.itemDeleted.subscribe { [unowned self] indexPath in
            self.viewModel.deleteItem(at: indexPath)
        }.disposed(by: disposeBag)
        
        //side menu
        sideMenuView = SideMenuView(mainScreenVC: self, frame: CGRect(
            x: -view.frame.width/1.5,
            y: 0,
            width: view.frame.width/1.5,
            height: view.frame.height
        ))
        sideMenuView.setup()
        self.navigationController?.view.addSubview(sideMenuView)
        
        //swipes Logic to open sideMenu
        let swipe = view.rx.panGesture().share(replay: 1)
        
        swipe.when(.began, .changed, .ended).subscribe { [weak self] event in
            guard let self = self else { return }
            guard let touch = event.element?.location(in: self.view) else { return }
            
            switch event.element?.state {
            case .began:
                self.viewModel.gesturePanBeginingPosition = touch.x
            case .changed:
                if self.viewModel.isSideMenuDisplayed {
                    guard touch.x < self.sideMenuView.frame.width else { return }
                    self.sideMenuView.frame.origin.x = touch.x - self.sideMenuView.frame.width
                } else {
                    guard self.viewModel.gesturePanBeginingPosition < 25 else { return }
                    guard touch.x < self.sideMenuView.frame.width else { return }
                    self.sideMenuView.frame.origin.x = touch.x - self.sideMenuView.frame.width
                }
            case .ended:
                self.viewModel.gesturePanBeginingPosition = 500
                
                if !self.viewModel.isSideMenuDisplayed {
                    if self.sideMenuView.frame.origin.x + self.sideMenuView.frame.width > 50 {
                        self.moveSideMenu(isDisplayed: false)
                    } else {
                        self.moveSideMenu(isDisplayed: true)
                    }
                } else {
                    if self.sideMenuView.frame.origin.x < -50 {
                        self.moveSideMenu(isDisplayed: true)
                    } else {
                        self.moveSideMenu(isDisplayed: false)
                    }
                }
            default: print("swipe error")
            }
        }.disposed(by: disposeBag)
    }
}

extension MainScreenViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }
}
