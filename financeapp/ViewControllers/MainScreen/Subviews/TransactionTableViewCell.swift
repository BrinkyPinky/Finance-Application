//
//  TransactionTableViewCell.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit

protocol TransactionTableViewCellRepresentable {
    var transactionModel: Transaction! { get set }
}

class TransactionTableViewCell: UITableViewCell, TransactionTableViewCellRepresentable {
    @IBOutlet private var transactionAmountLabel: UILabel!
    @IBOutlet private var transactionCategoryLabel: UILabel!
    @IBOutlet private var transactionDateLabel: UILabel!
    @IBOutlet private var transactionTypeView: UIView!
    
    var transactionModel: Transaction!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setup() {
        transactionTypeView.layer.cornerRadius = transactionTypeView.frame.width / 2
        
        transactionAmountLabel.text = transactionModel.amount
        transactionCategoryLabel.text = transactionModel.category
        transactionDateLabel.text = transactionModel.date?.description
        transactionTypeView.backgroundColor = transactionModel.isIncome ? .systemRed : .systemGreen
    }
}
