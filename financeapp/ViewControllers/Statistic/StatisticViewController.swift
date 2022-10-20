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
import SwiftUICharts
import SwiftUI

protocol StatisticViewControllerDelegate: AnyObject {
    var context: NSManagedObjectContext { get }
    func setProfitLabel(_ text: String)
    func setExpenditureLabel(_ text: String)
    func setChartView(_ data: ChartData)
}

class StatisticViewController: UIViewController, StatisticViewControllerDelegate {
    //interface elements
    @IBOutlet private var profitLabel: UILabel!
    @IBOutlet private var expenditureLabel: UILabel!
    @IBOutlet var chartView: UIView!
    
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
    
    func setProfitLabel(_ text: String) {
        profitLabel.text = text
    }
    
    func setExpenditureLabel(_ text: String) {
        expenditureLabel.text = text
    }
    
    func setChartView(_ data: ChartData) {
        let hostingChartView = UIHostingController(rootView: ChartView(
            size: CGSize(width: chartView.frame.width, height: chartView.frame.height),
            chartData: data)
        )
        hostingChartView.view.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        chartView.addSubview(hostingChartView.view)
    }
}
