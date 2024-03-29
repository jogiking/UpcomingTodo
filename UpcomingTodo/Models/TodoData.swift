//
//  Todo.swift
//  Todo
//
//  Created by turu on 2021/02/15.
//

import Foundation
import CoreData

protocol DisplayOrder {
    var displayOrder: Int? { get set }
}

class TodoData: Todo {
    var subTodoList: [Todo] = []
    var isOpen: Bool?
    var numberOfSubTodo: Int {
        get {
            return self.subTodoList.count
        }
    }
    var deadline: Date?
    var displaying: Bool?
    
    override init() {
        super.init()
        self.isOpen = false
        self.displaying = false
    }
    
    init(index: Int) {
        super.init()
        self.isOpen = false
        self.displaying = false
    }
}

class Todo: DisplayOrder {
    
    var displayOrder: Int?
    
    var title: String?
    var memo: String?
    var isFinish: Bool?
    var regDate: Date?
    var objectID: NSManagedObjectID?
    
    init() {
        self.isFinish = false
        self.regDate = Date()
    }
}

class CatalogData: DisplayOrder {
    var displayOrder: Int?
    
    var name: String?
    var regDate: Date?
    var objectID: NSManagedObjectID?
    var todoList: [TodoData] = []
}
