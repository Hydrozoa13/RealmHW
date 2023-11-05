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
        cell.configure(with: category)
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
        
        let doneAction = UIContextualAction(style: .destructive, title: "Done") { [weak self] _, _, _ in
            StorageManager.makeAllDone(category: category)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        deleteAction.backgroundColor = .systemRed
        editAction.backgroundColor = .lightGray
        doneAction.backgroundColor = .systemGreen
        
        let swipeActions = UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        
        return swipeActions
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TasksTVC,
           let indexPath = tableView.indexPathForSelectedRow {
            let category = categories[indexPath.row]
            vc.category = category
        }
    }
    
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
            alertTextField.text = category?.name
            alertTextField.placeholder = "Category name"
        }
        present(alertController, animated: true)
    }
}
