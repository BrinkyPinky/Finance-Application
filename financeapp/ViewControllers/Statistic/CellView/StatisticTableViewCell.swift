//
//  StatisticTableViewCell.swift
//  financeapp
//
//  Created by Егор Шилов on 20.10.2022.
//

import UIKit

protocol StatisticCellRepresentable {
    var statisticModel: StatisticModel! { get set }
}

class StatisticTableViewCell: UITableViewCell, StatisticCellRepresentable {

    @IBOutlet var categoryName: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    
    var statisticModel: StatisticModel! {
        didSet {
            setup()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setup() {
        percentLabel.text = "\(statisticModel.percent)%"
        progressView.progress = Float(statisticModel.percent)/100
        categoryName.text = statisticModel.categoryName
        amountLabel.text = statisticModel.amount
    }
}
