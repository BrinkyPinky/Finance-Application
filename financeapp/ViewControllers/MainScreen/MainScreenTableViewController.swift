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

class MainScreenTableViewController: UITableViewController {
    
    @IBOutlet private var sideMenuView: SideMenuView!
    private var viewModel: MainScreenTableViewModelProtocol!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        viewModel = MainScreenTableViewModel()
        
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
    
    @IBAction private func sideMenuButtonTapped(_ sender: Any) {
        moveSideMenu(isDisplayed: viewModel.isSideMenuDisplayed)
    }
    
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
}


// MARK: - Table view data source

extension MainScreenTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }
    
    //deleting
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
}
