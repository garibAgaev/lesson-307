//
//  ViewController.swift
//  lesson 307
//
//  Created by Garib Agaev on 14.09.2023.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    lazy var sortControl: UISegmentedControl = {
        let sortControl = UISegmentedControl(items: ["Date", "A-Z"])
        sortControl.selectedSegmentIndex = 0
        sortControl.addTarget(self, action: #selector(changeSegment), for: .valueChanged)
        return sortControl
    }()
    
    let cellId = "cellIdTaskListViewController"
    
    var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc private func addButtonPressed() {
        showAlert(setting: .add, completion: {})
    }
    
    @objc private func changeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            taskLists = taskLists.sorted(byKeyPath: "date")
        default:
            taskLists = taskLists.sorted(byKeyPath: "name")
        }
        tableView.reloadData()
    }
}

// MARK: - TableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskLists[indexPath.row]
        content.text = taskList.name
        let count = taskList.tasks.count
        switch count {
        case 0:
            cell.accessoryType = .none
        case taskList.tasks.filter("isComplete = true").count:
            cell.accessoryType = .checkmark
        default:
            cell.accessoryType = .none
        }
        content.secondaryText = "\(count)"
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = TasksViewController()
        viewController.taskList = taskLists[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, isDone in
            showAlert(setting: .delete) {
                StorageManager.shared.delete(taskList)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(setting: .edit(taskList)) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        doneAction.backgroundColor = .systemGreen
        editAction.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Setting View
private extension TaskListViewController {
    func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        createTempData()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
    }
    func setupNavigationController() {
        title = "Task Lists"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem
            .rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonPressed))
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.titleView = sortControl
    }
}

// MARK: - Setting
private extension TaskListViewController {
    func createTempData() {
        DataManager.shared.createTempData { [unowned self] in
            tableView.reloadData()
        }
    }
    
    func save(_ newVal: String) {
        StorageManager.shared.save(newVal) { taskList in
            let rowIndex = IndexPath(row: taskLists.count - 1, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
    
    func edit(_ taskList: TaskList, _ newVal: String) {
        StorageManager.shared.edit(taskList, newValue: newVal)
    }
}


// MARK: - Alert
private extension TaskListViewController {
    func showAlert(setting: Setting, completion: @escaping() -> Void) {
        let alert = UIAlertController(
            title: setting.title,
            message: setting.message,
            preferredStyle: .alert
        )
        var saveAction: UIAlertAction
        
        switch setting {
        case .add:
            saveAction = alert.getButton(
                title: setting.title,
                placeholder: "List Name"
            ) { [unowned self] newVal in
                save(newVal)
            }
        case .edit(let taskList):
            saveAction = alert.getButton(
                taskList: taskList,
                title: setting.title,
                placeholder: "List Name"
            ) { [unowned self] newVal in
                edit(taskList, newVal)
                completion()
            }
        case .delete:
            saveAction = alert.getButton(setting.actionTitle, completion)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        [saveAction, cancelAction].forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
}

// MARK: - Setting Contextual Alert
private extension TaskListViewController {
    enum Setting {
        case add
        case edit(TaskList)
        case delete
        
        var title: String {
            switch self {
            case .add:
                return "New List"
            case .edit:
                return "Edit List"
            case .delete:
                return "Delete List"
            }
        }
        
        var message: String {
            switch self {
            case .add, .edit:
                return "Please set title for new task list"
            case .delete:
                return "Are you sure you want to delete list?"
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
