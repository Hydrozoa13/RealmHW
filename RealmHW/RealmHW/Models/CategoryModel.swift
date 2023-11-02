//
//  CategoryModel.swift
//  RealmHW
//
//  Created by Евгений Лойко on 2.11.23.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}
