//
//  Todo.swift
//  Todo
//
//  Created by turu on 2021/02/15.
//

import Foundation
import CoreData

class TodoData: Todo {
    
    var subTodoList: [Todo] = []
    var isOpen: Bool?
    var numberOfSubTodo: Int {
        get {
            return self.subTodoList.count
        }
    }
    
    override init() {
        super.init()
        self.isOpen = false
        self.title = "todo-title"
        self.memo = "todo-memo"
    }
    
    init(index: Int) {
        super.init()
        self.isOpen = false
        self.title = "\(index): todo-title"
        self.memo = "\(index): todo-memo"
    }
}

class Todo {
    
    var title: String?
    var memo: String?
    var isFinish: Bool?
    var objectID: NSManagedObjectID?
    
    init() {
        self.title = "initial-title"
        self.memo = "initial-memo"
        self.isFinish = false
    }
}
