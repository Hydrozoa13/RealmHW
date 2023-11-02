//
//  StorageManager.swift
//  RealmHW
//
//  Created by Евгений Лойко on 2.11.23.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func getCategories() -> Results<Category> {
        realm.objects(Category.self)
    }
    
    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll error \(error)")
        }
    }
    
    static func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("saveCategory error \(error)")
        }
    }
}
