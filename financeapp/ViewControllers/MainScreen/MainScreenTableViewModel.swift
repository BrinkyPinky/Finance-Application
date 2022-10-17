//
//  MainScreenTableViewModel.swift
//  financeapp
//
//  Created by Егор Шилов on 16.10.2022.
//

import Foundation

protocol MainScreenTableViewModelProtocol {
    var isSideMenuDisplayed: Bool { get set }
    var gesturePanBeginingPosition: CGFloat { get set }
}

class MainScreenTableViewModel: MainScreenTableViewModelProtocol {
    var isSideMenuDisplayed: Bool = false
    
    var gesturePanBeginingPosition: CGFloat = 500
}
