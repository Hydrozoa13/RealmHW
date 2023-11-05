//
//  UITableViewCellExt.swift
//  RealmHW
//
//  Created by Евгений Лойко on 5.11.23.
//

import UIKit

extension UITableViewCell {
    
    func configure(with category: Category) {
        let completedTasks = category.tasks.filter("isCompleted = true")
        let notCompletedTasks = category.tasks.filter("isCompleted = false")
        
        textLabel?.text = category.name
        
        if !notCompletedTasks.isEmpty {
            detailTextLabel?.text = "\(notCompletedTasks.count)"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            detailTextLabel?.textColor = .systemRed
        } else if !completedTasks.isEmpty {
            detailTextLabel?.text = "✓"
            detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            detailTextLabel?.textColor = .systemGreen
        } else {
            detailTextLabel?.text = "0"
            detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            detailTextLabel?.textColor = .black
        }
    }
}
