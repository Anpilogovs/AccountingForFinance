//
//  SpendingModel.swift
//  AccountingForFinance
//
//  Created by Сергей Анпилогов on 15.02.2023.
//

import RealmSwift

class Spending: Object {
    
    @Persisted var category = ""
    @Persisted var cost = 1
    @Persisted var date = Date()
}


