//
//  TransactionCategoryModel.swift
//  financeapp
//
//  Created by Егор Шилов on 14.10.2022.
//

import RealmSwift

final class TransactionCategoryModel: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var staticID: Int
    @Persisted var dynamicID: Int //ordered by
    @Persisted var name: String
    @Persisted var isIncome: Bool

    convenience init(staticID: Int, dynamicID: Int, name: String, isIncome: Bool) {
        self.init()
        self.staticID = staticID
        self.dynamicID = dynamicID
        self.name = name
        self.isIncome = isIncome
    }
}
