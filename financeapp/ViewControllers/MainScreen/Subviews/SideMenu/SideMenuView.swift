//
//  SideMenuView.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import UIKit

protocol SideMenuViewDelegate {
    init(mainScreenVC: MainScreenTableViewController, frame: CGRect)
    func setup()
}

class SideMenuView: UIView, SideMenuViewDelegate {
    
    private lazy var sideMenuCellModel = [
        SideMenuCellModel(
            name: "Создать категорию",
            imageName: "list.dash",
            action: {
                self.performSegueWith(identifier: "showCreateCategoryViewController")
            }
        )
    ]
    
    unowned var mainScreenVC: MainScreenTableViewController!
    
    // MARK: Initialize
    
    required init(mainScreenVC: MainScreenTableViewController, frame: CGRect) {
        super.init(frame: frame)
        self.mainScreenVC = mainScreenVC
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup() {
        self.backgroundColor = .systemBackground
        let tableView = UITableView()
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ].forEach({ $0.isActive = true })
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell().classForCoder, forCellReuseIdentifier: "cell")
    }
    
    // MARK: Perform Segue With Storybord ID
    
    private func performSegueWith(identifier: String) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 50,
            initialSpringVelocity: 0,
            options: .curveEaseOut) {
                self.frame.origin.x -= self.frame.width
            }
        
        self.mainScreenVC.performSegue(withIdentifier: identifier, sender: nil)
    }
}

// MARK: Table View Data Source

extension SideMenuView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sideMenuCellModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cellModel = sideMenuCellModel[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = cellModel.name
        config.image = UIImage(systemName: cellModel.imageName)
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sideMenuCellModel[indexPath.row].action()
    }
}