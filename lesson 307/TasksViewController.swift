//
//  TasksViewController.swift
//  lesson 307
//
//  Created by Garib Agaev on 14.09.2023.
//

import UIKit
import RealmSwift

final class TasksViewController: UITableViewController {
    
    let cellId = "cellIdTasksViewController"
    
    var taskList: TaskList!
    
    private var tasks: [Results<Task>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()
    }
    
    @objc private func addButtonPressed() {
        showAlert(setting: .add, completion: {})
    }
}

// MARK: - TableViewDataSource
extension TasksViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = tasks[indexPath.section][indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.section][indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, isDone in
            showAlert(setting: .delete) {
                StorageManager.shared.delete(task)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(setting: .edit(task)) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { [unowned self] _, _, isDone in
            let section = 1 - indexPath.section
            let row = tasks[section].firstIndex{ $0.date > task.date } ?? tasks[section].count
            let newIndexPath = IndexPath(row: row, section: section)
            StorageManager.shared.done(task)
            tableView.beginUpdates()
            tableView.moveRow(at: indexPath, to: newIndexPath)
            tableView.endUpdates()
            isDone(true)
        }
        
        doneAction.backgroundColor = .systemGreen
        editAction.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
}

// MARK: - Settng View
private extension TasksViewController {
    func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tasks = [false, true].map { taskList.tasks.filter("isComplete = \($0)") }
    }
    func setupNavigationController() {
        title = taskList.name
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
}

// MARK: - Settng
private extension TasksViewController {
    func save(task: String, withNote note: String) {
        StorageManager.shared.save(task, withNote: note, to: taskList) { task in
            let rowIndex = IndexPath(row: tasks[0].count - 1, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
    
    func edit(task: Task, withTitle title: String, andNote note: String) {
        StorageManager.shared.edit(task, newValue: title, newNote: note)
    }
}

// MARK: - Alert
private extension TasksViewController {
    func showAlert(setting: Setting, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: setting.title,
                                      message: setting.message,
                                      preferredStyle: .alert)
        var saveAction: UIAlertAction
        
        let placeholders = ["New Task", "Note"]
        switch setting {
        case .add:
            saveAction = alert.getButton(
                title: setting.title,
                placeholders: placeholders
            ) { [unowned self] (task, note) in
                save(task: task, withNote: note)
            }
        case .edit(let task):
            saveAction = alert.getButton(
                task: task,
                title: setting.title,
                placeholders: placeholders
            ) { [unowned self] (title, note) in
                edit(task: task, withTitle: title, andNote: note)
                completion()
            }
        case .delete:
            saveAction = alert.getButton(setting.title, completion)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        [saveAction, cancelAction].forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
}

// MARK: - Setting Contextual Alert
private extension TasksViewController {
    enum Setting {
        case add
        case edit(Task)
        case delete
        
        var title: String {
            switch self {
            case .add:
                return "New Task"
            case .edit:
                return "Edit Task"
            case .delete:
                return "Delete Task"
            }
        }
        
        var message: String {
            switch self {
            case .add, .edit:
                return "What do you want to do?"
            case .delete:
                return "Are you sure you want to delete task?"
            }
        }
        
        var actionTitle: String {
            switch self {
            case .add:
                return "Save"
            case .edit:
                return "Update"
            case .delete:
                return "Delete"
            }
        }
    }
}
