//
//  CategoriesTVC.swift
//  RealmHW
//
//  Created by Евгений Лойко on 2.11.23.
//

import UIKit
import RealmSwift

class CategoriesTVC: UITableViewController {
    
    var categories: Results<Category>!

    override func viewDidLoad() {
        super.viewDidLoad()
        categories = StorageManager.getCategories().sorted(byKeyPath: "name")
        setupUI()
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        let byKeyPath = sender.selectedSegmentIndex == 0 ? "name" : "date"
        categories = categories.sorted(byKeyPath: byKeyPath)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let category = categories[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            StorageManager.deleteCategory(category: category)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { [weak self] _, _, _ in
            self?.alertForAddAndUpdatesCategories(category: category, indexPath: indexPath)
        }
        
        deleteAction.backgroundColor = .red
        editAction.backgroundColor = .lightGray
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return swipeActions
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Private functions
    
    private func setupUI() {
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                  action: #selector(addBarButtonSystemItemSelector))
        navigationItem.setRightBarButton(add, animated: true)
    }
    
    //MARK: - Obj-c
    
    @objc
    private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesCategories()
    }

    private func alertForAddAndUpdatesCategories(category: Category? = nil,
                                                 indexPath: IndexPath? = nil) {
        let title = category == nil ? "New category" : "Edit category"
        let message = "Please insert category name"
        let doneButtonName = category == nil ? "Save" : "Update"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { [weak self] _ in
            guard let self,
                  let indexPath,
                  let newCategory = alertTextField.text,
                  !newCategory.isEmpty else { return }
            
            if let category = category {
                StorageManager.editCategory(category: category, newCategoryName: newCategory)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                let category = Category()
                category.name = newCategory
                StorageManager.saveCategory(category: category)
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { textField in
            alertTextField = textField
            alertTextField.placeholder = "Category name"
        }
        present(alertController, animated: true)
    }
}
