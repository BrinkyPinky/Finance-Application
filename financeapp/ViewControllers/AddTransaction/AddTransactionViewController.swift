//
//  AddTransactionViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    @IBOutlet private var transactionAmountTextField: UITextField!
    private var viewModel: AddTransactionViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AddTransactionViewModel()
        setup()
    }
    
    private func setup() {
        let label = UILabel()
        label.text = "₽"
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 30)
        transactionAmountTextField.setUnderLine()
        transactionAmountTextField.rightView = label
        transactionAmountTextField.rightViewMode = .always
    }
}

extension AddTransactionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.outcomingCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = viewModel.outcomingCategories[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.categoryNameLabel.text = category
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.backgroundColor = .red
    }
}
