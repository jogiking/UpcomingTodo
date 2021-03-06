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
        let sortDescriptor = NSSortDescriptor(key: "displayorder", ascending: true)
        fetchRequestOfCatalogMO.sortDescriptors = [sortDescriptor]

        do {
            let catalogResutSet = try self.context.fetch(fetchRequestOfCatalogMO)
            for catalog in catalogResutSet {
                let catalogData = CatalogData()
                catalogData.regDate = catalog.regdate
                catalogData.name = catalog.name
                catalogData.objectID = catalog.objectID
                catalogData.displayOrder = Int(catalog.displayorder)
                
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
    
    func insert(_ data: CatalogData) -> CatalogMO {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Catalog", into: self.context) as! CatalogMO

        object.name = data.name
        object.regdate = data.regDate
        object.displayorder = Int16(data.displayOrder!)
        
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
        return object
    }
    
    func insert(_ data: TodoData, catalogObjectID: NSManagedObjectID) -> TodoMO {
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
        return object
    }
    
    func insert(_ data: Todo, todoDataObjectID: NSManagedObjectID) -> SubTodoMO {
        let object = NSEntityDescription.insertNewObject(forEntityName: "SubTodo", into: self.context) as! SubTodoMO
        object.title = data.title
        object.memo = data.memo
        object.isfinish = data.isFinish!
        object.regdate = data.regDate
        
        let todoDataObject = context.object(with: todoDataObjectID) as! TodoMO
        object.todo = todoDataObject
        
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
        return object
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
    
    func edit(_ objectID: NSManagedObjectID, item: Todo) -> Bool {
        
        let object = context.object(with: objectID)
        
        object.setValue(item.title, forKey: "title")
        object.setValue(item.memo, forKey: "memo")
        object.setValue(item.regDate, forKey: "regdate")
        object.setValue(item.isFinish, forKey: "isfinish")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func updateDisplayOrder(todoList: [Todo], insertIndex at: Int) {
        guard at < todoList.count - 1 else { return }
        
        for index in at + 1...todoList.count - 1 {
            let objID = todoList[index].objectID
            let object = context.object(with: objID!)
            object.setValue(index, forKey: "displayorder")
        }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
    
    func updateDisplayOrder(todoList: [Todo], removeIndex at: Int) {
        guard at < todoList.count - 1 else { return }
        
        for index in at...todoList.count - 1 {
            let objID = todoList[index].objectID
            let object = context.object(with: objID!)
            object.setValue(index, forKey: "displayorder")
        }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
    
//    func updateDisplayOrder(todoList: [Todo], removeIndex at: Int) {
//        guard at < todoList.count - 1 else { return }
//        
//        for index in at...todoList.count - 1 {
//            let objID = todoList[index].objectID
//            let object = context.object(with: objID!)
//            object.setValue(index, forKey: "displayorder")
//        }
//        do {
//            try context.save()
//        } catch {
//            context.rollback()
//        }
//    }
    
    func updateDisplayOrder(removeCatalogIndex at: Int) {
        let indexOfLast = appDelegate.myData.count - 1
        guard at < indexOfLast else { return }
        
        for index in at...indexOfLast {
            let objID = appDelegate.myData[index].objectID
            let object = context.object(with: objID!)
            object.setValue(index, forKey: "displayorder")
        }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
    

    func saveCatalogContext(_ discardingCatalog: CatalogData, discardingCatalogObjectID: NSManagedObjectID) {
        
        if delete(discardingCatalogObjectID) {
            let catalogMO = insert(discardingCatalog)
            for todoData in discardingCatalog.todoList {
                let todoMO = insert(todoData, catalogObjectID: catalogMO.objectID)
                for subTodo in todoData.subTodoList {
                    _ = insert(subTodo, todoDataObjectID: todoMO.objectID)
                }
            }
            
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
}
