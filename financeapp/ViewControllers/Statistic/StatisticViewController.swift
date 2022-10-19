//
//  StatisticViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 19.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CoreData

protocol StatisticViewControllerDelegate: AnyObject {
    var context: NSManagedObjectContext { get }
    func updateProfitLabel(_ text: String)
    func updateExpenditureLabel(_ text: String)
}

class StatisticViewController: UIViewController, StatisticViewControllerDelegate {
    //Labels
    @IBOutlet private var profitLabel: UILabel!
    @IBOutlet private var expenditureLabel: UILabel!

    //tableView
    @IBOutlet private var tableView: UITableView!
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfStatisticModel>{ dataSource, tableView, indexPath, item in
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StatisticCellRepresentable
        cell.statisticModel = item
        return cell as! UITableViewCell
    } titleForHeaderInSection: { dataSource, index in
        dataSource.sectionModels[index].header
    }
    
    //context
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //disposeBag
    let disposeBag = DisposeBag()
    
    //viewModel
    private var viewModel: StatisticViewModelProtocol!
    
    // MARK: ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = StatisticViewModel(self)
        viewModel.getInformation()
        
        //tableView
        viewModel.sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        tableView.rx.rowHeight.onNext(65)
    }
    
    // MARK: Update Interface Values
    
    func updateProfitLabel(_ text: String) {
        profitLabel.text = text
    }
    
    func updateExpenditureLabel(_ text: String) {
        expenditureLabel.text = text
    }
}
