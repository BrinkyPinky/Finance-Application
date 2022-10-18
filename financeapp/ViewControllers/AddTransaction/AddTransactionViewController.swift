//
//  AddTransactionViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

protocol AddTransactionViewControllerDelegate: AnyObject {
    var context: NSManagedObjectContext { get }
}

class AddTransactionViewController: UIViewController, AddTransactionViewControllerDelegate {
    
    @IBOutlet private var transactionAmountTextField: UITextField!
    @IBOutlet private var dateTextField: UITextField!
    @IBOutlet private var incomeButton: UIButton!
    @IBOutlet private var outcomeButton: UIButton!
    @IBOutlet private var categoriesCollectionView: UICollectionView!
    @IBOutlet private var transactionCommentTextView: UITextView!
    private let datePicker = UIDatePicker()
    
    private var viewModel: AddTransactionViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    unowned var mainScreenDelegate: MainScreenViewControllerTransactionUpdateDelegate!
    
    // MARK: ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AddTransactionViewModel(viewController: self)
        setup()
    }
    
    // MARK: buttons Actions
    
    @IBAction private func incomeButtonAction(_ sender: Any) {
        viewModel.isIncome = true
        outcomeButton.tintColor = .opaqueSeparator
        incomeButton.tintColor = .systemGreen
        categoriesCollectionView.reloadData()
    }
    
    @IBAction private func outcomeButtonAction(_ sender: Any) {
        viewModel.isIncome = false
        incomeButton.tintColor = .opaqueSeparator
        outcomeButton.tintColor = .systemRed
        categoriesCollectionView.reloadData()
    }
    
    @IBAction private func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func saveButtonAction(_ sender: Any) {
        viewModel.saveTransaction(
            amount: transactionAmountTextField.text,
            date: datePicker.date,
            categoryIndexPath: categoriesCollectionView.indexPathsForSelectedItems?.first,
            comment: transactionCommentTextView.text
        ) { message in
            showAlert(message: message)
        } completion: {
            mainScreenDelegate.transactionsDidChange()
            dismiss(animated: true)
        }
    }
    
    // MARK: show Alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: Categories Collection View

extension AddTransactionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.categoryNameLabel.text = viewModel.categoryNameForItem(at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.contentView.backgroundColor = .red
    }
}

// MARK: Setup

extension AddTransactionViewController {
    private func setup() {
        self.hideKeyboardWhenTappedAround()
        
        //transactionAmountTextField
        let rubIcon = UILabel()
        rubIcon.text = "₽"
        rubIcon.textColor = .secondaryLabel
        rubIcon.font = UIFont.systemFont(ofSize: 30)
        transactionAmountTextField.setUnderLine()
        transactionAmountTextField.rightView = rubIcon
        transactionAmountTextField.rightViewMode = .always
        transactionAmountTextField.clearsOnBeginEditing = true
        
        transactionAmountTextField.rx.text.subscribe { [unowned self] stringNumber in
            viewModel.checkForDotsInAmountOfTransaction(&transactionAmountTextField.text)
        }.disposed(by: disposeBag)
        
        transactionAmountTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit]).subscribe { [unowned self] _ in
            transactionAmountTextField.text = viewModel.formatAmountOfTransactionOnEditingEnd(
                transactionAmountTextField.text
            )
        }.disposed(by: disposeBag)
        
        //collection view insets
        categoriesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        
        //datePicker
        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calendarIcon.tintColor = .secondaryLabel
        dateTextField.setUnderLine()
        dateTextField.tintColor = .clear
        dateTextField.inputView = datePicker
        dateTextField.rightView = calendarIcon
        dateTextField.rightViewMode = .always
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        datePicker.rx.date.subscribe { [unowned self] date in
            dateTextField.text = viewModel.formatDate(date.element)
        }.disposed(by: disposeBag)
        
        //comment TextView
        transactionCommentTextView.layer.cornerRadius = 10
        transactionCommentTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        transactionCommentTextView.layer.borderWidth = 0.5
        transactionCommentTextView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}
