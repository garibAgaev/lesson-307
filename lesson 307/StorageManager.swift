//
//  StorageManager.swift
//  lesson 307
//
//  Created by Garib Agaev on 14.09.2023.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try! Realm()
    private init() {}
    
    func save(_ taskLists: [TaskList]) async {
        wrire {
            realm.add(taskLists)
        }
    }
    
    func save(_ taskList: String, completion: (TaskList) -> Void) {
        wrire {
            let taskList = TaskList(value: ["name": taskList])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    func delete(_ taskList: TaskList) {
        wrire {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
        }
    }
    
    func done(_ taskList: TaskList) {
        wrire {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    func edit(_ taskList: TaskList, newValue: String) {
        wrire {
            taskList.name = newValue
        }
    }
    
    // MARK: - Task
    func save(_ task: String, withNote note: String, to taskList: TaskList, completion: (Task) -> Void) {
        wrire {
            let task = Task(value: [
                "name": task,
                "note": note
            ])
            taskList.tasks.append(task)
            completion(task)
        }
    }
    
    func delete(_ task: Task) {
        wrire {
            realm.delete(task)
        }
    }
    
    func done(_ task: Task) {
        wrire {
            task.isComplete = !task.isComplete
        }
    }
    
    func edit(_ task: Task, newValue: String, newNote: String) {
        wrire {
            task.name = newValue
            task.note = newNote
        }
    }
    
    private func wrire(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

private extension StorageManager {
    
}
