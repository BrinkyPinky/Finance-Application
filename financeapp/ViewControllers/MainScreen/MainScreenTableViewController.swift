//
//  MainScreenTableViewController.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit

class MainScreenTableViewController: UITableViewController {
    
    @IBOutlet private var sideMenuView: SideMenuView!
    
    override func viewDidLoad() {
        //side menu
        sideMenuView = SideMenuView(mainScreenVC: self, frame: CGRect(
            x: -view.frame.width/1.5,
            y: 0,
            width: view.frame.width/1.5,
            height: view.frame.height
        ))
        sideMenuView.setup()
        self.navigationController?.view.addSubview(sideMenuView)
    }
    
    
    @IBAction private func sideMenuButtonTapped(_ sender: Any) {
        showSideMenu(true)
    }
    
    private func showSideMenu(_ show: Bool) {
        if show {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 50,
                initialSpringVelocity: 0,
                options: .curveEaseInOut) {
                    self.sideMenuView.frame.origin.x += self.sideMenuView.frame.width
                }
        } else {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 50,
                initialSpringVelocity: 0,
                options: .curveEaseInOut) {
                    
                }
        }
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
