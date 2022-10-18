//
//  AmountOfMoneyDataManager.swift
//  financeapp
//
//  Created by Егор Шилов on 19.10.2022.
//

import Foundation

class AmountOfMoneyDataManager {
    static let shared = AmountOfMoneyDataManager()
    
    func changeValue(_ onValue: Double, isNeedToIncrease: Bool) {
        let currentValue = UserDefaults.standard.double(forKey: "amountOfMoney")
        
        UserDefaults.standard.set(
            isNeedToIncrease ? onValue + currentValue : currentValue - onValue,
            forKey: "amountOfMoney"
        )
    }
    
    func getValue() -> Double {
        UserDefaults.standard.double(forKey: "amountOfMoney")
    }
}
