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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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

    private func alertForAddAndUpdatesCategories() {
        let title = "New category"
        let message = "Please insert category name"
        let doneButtonName = "Save"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { [weak self] _ in
            guard let self,
                  let newCategory = alertTextField.text,
                  !newCategory.isEmpty else { return }
            let category = Category()
            category.name = newCategory
            StorageManager.saveCategory(category: category)
            self.tableView.reloadData()
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
