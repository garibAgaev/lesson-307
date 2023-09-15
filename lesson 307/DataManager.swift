//
//  DataManager.swift
//  lesson 307
//
//  Created by Garib Agaev on 14.09.2023.
//

import Foundation
import RealmSwift

final class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempData(completion: @escaping() -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            let shoppingList = TaskList(value: [
                "name": "Shopping List",
                "tasks": [
                    ["name": "Milk",
                     "note": "2L"],
                    ["name": "Bread",
                     "isComplete": true],
                    ["name": "Apples",
                     "note": "2Kg"] as [String : Any],
                ]
            ] as [String : Any])
//            shoppingList.name = "Shopping List"
//
//            let milk = Task()
//            milk.name = "Milk"
//            milk.note = "2L"
//
//            let bread = Task()
//            bread.name = "Bread"
//            bread.isComplete = true
//
//            let apples = Task()
//            apples.name = "Apples"
//            apples.note = "2Kg"
//
//            shoppingList.tasks.insert(contentsOf: [milk, bread, apples], at: 0)
            
            let moviesList = TaskList(value: [
                "name": "Movies List",
                "tasks": [
                    ["name": "Best film ever"] as [String : Any],
                    ["name": "The best of the best",
                     "note": "Must have",
                     "isComplete": true]
                ]
            ] as [String : Any])
            
//            Task {
//                await StorageManager.shared.save([shoppingList, moviesList])
//            }
        }
    }
}
