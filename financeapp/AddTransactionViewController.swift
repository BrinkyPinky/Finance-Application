//
//  AddTransactionViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import UIKit

class AddTransactionViewController: UIViewController {
            
    @IBOutlet var transactionAmountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionAmountTextField.setUnderLine()
        
        let label = UILabel()
        label.text = "$"
        label.textColor = .opaqueSeparator
        label.font = UIFont.systemFont(ofSize: 30)
        
        transactionAmountTextField.rightView = label
        transactionAmountTextField.rightViewMode = .always
    }
}
