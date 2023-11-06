//
//  TasksTVC.swift
//  RealmHW
//
//  Created by Евгений Лойко on 2.11.23.
//

import UIKit
import RealmSwift

enum TasksTVCFlow {
    case addingTask
    case editingTask(task: Task)
}

struct TextAlertData {
    
    let titleForAlert = "Task value"
    var messageForAlert: String
    let doneBtnForAlert: String
    let cancelTxt = "Cancel"
    
    let newTFPlaceholder = "New task"
    let noteTFPlaceholder = "Note"
    
    var taskName: String?
    var taskNote: String?
    
    init(tasksTVCFlow: TasksTVCFlow) {
        switch tasksTVCFlow {
        case .addingTask:
            messageForAlert = "Please insert new task value"
            doneBtnForAlert = "Save"
        case .editingTask(let task):
            messageForAlert = "Please edit your task"
            doneBtnForAlert = "Update"
            taskName = task.name
            taskNote = task.note
        }
    }
}

class TasksTVC: UITableViewController {
    
    var category: Category?
    private var completedTasks: Results<Task>!
    private var notCompletedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        filteringTasks()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? notCompletedTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Not completed tasks" : "Completed tasks"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            StorageManager.deleteTask(task: task)
            self?.filteringTasks()
        }
        
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { [weak self] _, _, _ in
            self?.alertForAddAndUpdatesTask(tasksTVCFlow: .editingTask(task: task))
        }
        
        let doneText = task.isCompleted ? "Not done" : "Done"
        let doneAction = UIContextualAction(style: .destructive, title: doneText) { [weak self] _, _, _ in
            StorageManager.changeCompletion(task: task)
            self?.filteringTasks()
        }
        
        deleteAction.backgroundColor = .systemRed
        editAction.backgroundColor = .lightGray
        doneAction.backgroundColor = doneText == "Not done" ? .systemYellow : .systemGreen
        
        let swipeActions = UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        
        return swipeActions
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to : IndexPath) {
        let task = fromIndexPath.section == 0 ? notCompletedTasks[fromIndexPath.row] : completedTasks[fromIndexPath.row]
        let isCompleted = to.section == 0 ? false : true
        let currentArray = fromIndexPath.section == 0 ? notCompletedTasks : completedTasks
        
        guard let category,
              let count = currentArray?.count else { return }
        var destination = to.section == 0 ? count - 1 - to.row : count - 1 + to.row
        
        if fromIndexPath.section == to.section {
            destination = to.row
        }
        
        StorageManager.moveTask(category: category, from: fromIndexPath.row, to: destination)
        StorageManager.isCompleted(task: task, isCompleted: isCompleted)
    }

    //MARK: - Private functions
    
    private func filteringTasks() {
        completedTasks = category?.tasks.filter("isCompleted = true")
        notCompletedTasks = category?.tasks.filter("isCompleted = false")
        tableView.reloadData()
    }
    
    private func setupUI() {
        title = category?.name
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                  action: #selector(addBarButtonSystemItemSelector))
        navigationItem.setRightBarButtonItems([editButtonItem, add], animated: true)
    }
    
    //MARK: - Obj-c
    
    @objc
    private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesTask(tasksTVCFlow: .addingTask)
    }

    private func alertForAddAndUpdatesTask(tasksTVCFlow: TasksTVCFlow) {
        
        let textAlertData = TextAlertData(tasksTVCFlow: tasksTVCFlow)
        
        let alertController = UIAlertController(title: textAlertData.titleForAlert,
                                                message: textAlertData.messageForAlert,
                                                preferredStyle: .alert)
        
        var taskTF: UITextField!
        var noteTF: UITextField!
        
        alertController.addTextField { textField in
            taskTF = textField
            taskTF.placeholder = textAlertData.newTFPlaceholder
            taskTF.text = textAlertData.taskName
        }
        
        alertController.addTextField { textField in
            noteTF = textField
            noteTF.placeholder = textAlertData.noteTFPlaceholder
            noteTF.text = textAlertData.taskNote
        }
        
        let saveAction = UIAlertAction(title: textAlertData.doneBtnForAlert,
                                       style: .default) { [weak self] _ in
            guard let self,
                  let category,
                  let newTask = taskTF.text, !newTask.isEmpty,
                  let newNote = noteTF.text, !newNote.isEmpty else { return }
            
            switch tasksTVCFlow {
                case .addingTask:
                    let task = Task()
                    task.name = newTask
                    task.note = newNote
                    StorageManager.saveTask(category: category, task: task)
                case .editingTask(let task):
                StorageManager.editTask(task: task, newName: newTask, newNote: newNote)
            }
            self.filteringTasks()
        }
        
        let cancelAction = UIAlertAction(title: textAlertData.cancelTxt, style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
