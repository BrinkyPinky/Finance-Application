//
//  Transaction+CoreDataProperties.swift
//  financeapp
//
//  Created by Егор Шилов on 18.10.2022.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var comment: String
    @NSManaged public var date: Date
    @NSManaged public var isIncome: Bool

}

extension Transaction : Identifiable {

}
