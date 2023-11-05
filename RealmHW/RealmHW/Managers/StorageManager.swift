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
    
    static func deleteCategory(category: Category) {
        do {
            try realm.write {
                let tasks = category.tasks
                realm.delete(tasks)
                realm.delete(category)
            }
        } catch {
            print("deleteCategory error \(error)")
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
    
    static func editCategory(category: Category,
                             newCategoryName: String) {
        do {
            try realm.write {
                category.name = newCategoryName
            }
        } catch {
            print("editCategory error \(error)")
        }
    }
    
    static func makeAllDone(category: Category) {
        do {
            try realm.write {
                category.tasks.setValue(true, forKey: "isCompleted")
            }
        } catch {
            print("makeAllDone error \(error)")
        }
    }
    
    static func saveTask(category: Category, task: Task) {
        do {
            try realm.write {
                category.tasks.append(task)
            }
        } catch {
            print("saveTask error \(error)")
        }
    }
    
    static func editTask(task: Task, newName: String, newNote: String) {
        do {
            try realm.write {
                task.name = newName
                task.note = newNote
            }
        } catch {
            print("editTask error \(error)")
        }
    }
}
