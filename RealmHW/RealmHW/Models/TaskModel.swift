//
//  TaskModel.swift
//  RealmHW
//
//  Created by Евгений Лойко on 2.11.23.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isCompleted = false
}
