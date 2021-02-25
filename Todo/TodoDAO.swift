//
//  TodoDAO.swift
//  Todo
//
//  Created by turu on 2021/02/23.
//

import UIKit
import CoreData

class TodoDAO {
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func fetch() -> [CatalogData] {
        
        var data = [CatalogData]()
        
        let fetchRequestOfCatalogMO: NSFetchRequest<CatalogMO> = CatalogMO.fetchRequest()

        do {
            let catalogResutSet = try self.context.fetch(fetchRequestOfCatalogMO)
            for catalog in catalogResutSet {
                let catalogData = CatalogData()
                catalogData.regDate = catalog.regdate
                catalogData.name = catalog.name
                catalogData.objectID = catalog.objectID
                
                let todos = catalog.todos?.array as! [TodoMO]
                for todo in todos {
                    let todoData = TodoData()
                    todoData.regDate = todo.regdate
                    todoData.isFinish = todo.isfinish
                    todoData.title = todo.title
                    todoData.memo = todo.memo
                    todoData.objectID = todo.objectID
                    
                    let subTodos = todo.subTodos?.array as! [SubTodoMO]
                    for subTodo in subTodos {
                        let subTodoData = Todo()
                        subTodoData.title = subTodo.title
                        subTodoData.memo = subTodo.memo
                        subTodoData.objectID = subTodo.objectID
                        subTodoData.regDate = subTodo.regdate
                        subTodoData.isFinish = subTodo.isfinish
                        
                        todoData.subTodoList.append(subTodoData)
                    }
                    catalogData.todoList.append(todoData)
                }
                data.append(catalogData)
            }
            
        } catch let e as NSError {
            NSLog("An error has occurred.", e.localizedDescription)
        }
        
        return data
    }
    
    func insert(_ data: CatalogData) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Catalog", into: self.context) as! CatalogMO

        object.name = data.name
        object.regdate = data.regDate
        
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
    }
    
    func insert(_ data: TodoData, catalogObjectID: NSManagedObjectID) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: self.context) as! TodoMO
        object.title = data.title
        object.memo = data.memo
        object.isfinish = data.isFinish!
        object.regdate = data.regDate
        
        let catalogObject = context.object(with: catalogObjectID) as! CatalogMO
        object.catalogList = catalogObject
        
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
    }
    
    func insert(_ data: TodoData, subTodoObjectID: NSManagedObjectID) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "SubTodo", into: self.context) as! SubTodoMO
        object.title = data.title
        object.memo = data.memo
        object.isfinish = data.isFinish!
        object.regdate = data.regDate
        
        let todoObject = context.object(with: subTodoObjectID) as! TodoMO
        object.todo = todoObject
        
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
    }
    
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        let object = self.context.object(with: objectID)
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
            return false
        }
    }
}
