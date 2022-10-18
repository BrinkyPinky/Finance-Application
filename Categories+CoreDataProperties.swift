//
//  Categories+CoreDataProperties.swift
//  financeapp
//
//  Created by Егор Шилов on 18.10.2022.
//
//

import Foundation
import CoreData
import Differentiator


extension Categories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categories> {
        return NSFetchRequest<Categories>(entityName: "Categories")
    }

    @NSManaged public var isIncome: Bool
    @NSManaged public var name: String
    @NSManaged public var orderID: Int64

}

extension Categories: IdentifiableType {
    public var identity: UUID {
        return UUID()
    }
    
    public typealias Identity = UUID
}
