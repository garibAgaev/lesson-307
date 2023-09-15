//
//  ExtensionAlectController.swift
//  lesson 307
//
//  Created by Garib Agaev on 14.09.2023.
//

import UIKit

extension UIAlertController {
    func getButton(_ title: String, _ completion: @escaping() -> Void) -> UIAlertAction {
        UIAlertAction(title: title, style: .default) { _ in
            completion()
        }
    }
    
    func getButton(taskList: TaskList? = nil, title: String, placeholder: String, completion: @escaping(String) -> Void) -> UIAlertAction {
        addTextField { textField in
            textField.placeholder = placeholder
            textField.text = taskList?.name
        }
        
        let action = UIAlertAction(title: title, style: .default) { [unowned self] _ in
            guard
                let newValue = textFields?.first?.text,
                !newValue.isEmpty
            else { return }
            completion(newValue)
        }
        return action
    }

    func getButton(task: Task? = nil, title: String, placeholders: [String], completion: @escaping(String, String) -> Void) -> UIAlertAction {
        for (index, placeholder) in placeholders.enumerated() {
            addTextField { textField in
                textField.placeholder = placeholder
                switch index {
                case 0:
                    textField.text = task?.name
                default:
                    textField.text = task?.note
                }
            }
        }
        
        let action = UIAlertAction(title: title, style: .default) { [unowned self] _ in
            guard
                let newValue = textFields?.first?.text,
                !newValue.isEmpty
            else { return }
            if let note = textFields?.last?.text {
                completion(newValue, note)
            } else {
                completion(newValue, "")
            }
        }
        return action
    }
}
