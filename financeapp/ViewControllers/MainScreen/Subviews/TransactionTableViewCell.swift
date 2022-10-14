//
//  TransactionTableViewCell.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet var transactionAmountLabel: UILabel!
    @IBOutlet var transactionCategoryLabel: UILabel!
    @IBOutlet var transactionDateLabel: UILabel!
    @IBOutlet var transactionTypeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setup() {
        transactionTypeView.layer.cornerRadius = transactionTypeView.frame.width / 2
    }
}
