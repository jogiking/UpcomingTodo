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
    
    func fetchUpcomingTodoList() -> [TodoData] {
        var todoDataList = [TodoData]()
        let fetchRequest: NSFetchRequest<TodoMO> = TodoMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "deadline", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "deadline != nil")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let todoDataResultSet = try self.context.fetch(fetchRequest)
            for todoDataMO in todoDataResultSet {
                let todoData = TodoData()
                todoData.title = todoDataMO.title
                todoData.memo = todoDataMO.memo
                todoData.deadline = todoDataMO.deadline
                todoData.objectID = todoDataMO.objectID
                todoData.regDate = todoDataMO.regdate
                todoData.isFinish = todoDataMO.isfinish
                todoData.displaying = todoDataMO.displaying
                
                let subTodoMO = todoDataMO.subTodos?.array as! [SubTodoMO]
                for subTodo in subTodoMO {
                    let subTodoData = Todo()
                    subTodoData.title = subTodo.title
                    subTodoData.memo = subTodo.memo
                    subTodoData.objectID = subTodo.objectID
                    subTodoData.regDate = subTodo.regdate
                    subTodoData.isFinish = subTodo.isfinish
                    
                    todoData.subTodoList.append(subTodoData)
                }
                
                todoDataList.append(todoData)
            }
        } catch let e as NSError {
            NSLog("An error has occurred.", e.localizedDescription)
        }
        return todoDataList
    }
    
    func fetch(keyword text: String? = nil) -> [CatalogData] {
        
        var data = [CatalogData]()
        
        let fetchRequestOfCatalogMO: NSFetchRequest<CatalogMO> = CatalogMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "displayorder", ascending: true)
        fetchRequestOfCatalogMO.sortDescriptors = [sortDescriptor]
        
        if let t = text, t.isEmpty == false {
            fetchRequestOfCatalogMO.predicate = NSPredicate(format: "title CONTAINS[c] %@ OR memo CONTAINS[c] %@", t, t)
        }

        do {
            let catalogResultSet = try self.context.fetch(fetchRequestOfCatalogMO)
            for catalog in catalogResultSet {
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
                    todoData.isOpen = todo.isopen
                    todoData.objectID = todo.objectID
                    todoData.deadline = todo.deadline
                    todoData.displaying = todo.displaying
                    
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
            print("Fetch Fail.")
            NSLog("An error has occurred.", e.localizedDescription)
        }
        
        return data
    }
    
    func insert(_ data: CatalogData) -> CatalogMO {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: "Catalog", into: self.context) as? CatalogMO else {
            print("여기서 에러 발생")
            return CatalogMO()
        }

        object.name = data.name
        object.regdate = data.regDate
        object.displayorder = Int16(data.displayOrder!)
        print("afterinsertCatalogMO")
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
        object.isopen = data.isOpen!
        object.deadline = data.deadline
        object.displaying = data.displaying!
        
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
            print("delete success")
            return true
        } catch let e as NSError {
            print("delete fail")
            NSLog("An error has occurred : %s", e.localizedDescription)
            return false
        }
    }
    
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
    
    func updateDisplayOrder() {
        guard appDelegate.myData.count > 1 else { return }
        let indexOfLast = appDelegate.myData.count - 1
        
        for index in 0...indexOfLast {
            appDelegate.myData[index].displayOrder = index
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
    
    func updateDisplayingAttribute(_ objectID: NSManagedObjectID) -> Bool {
        // 해당하는 objectID만 displaying를 true로 바꾸고 나머지는 전부 false로 덮어씌운다.
        let upcomingTodoList = fetchUpcomingTodoList()
        // 전부 false로 만들고
        for todoData in upcomingTodoList {
            let object = context.object(with: todoData.objectID!)
            object.setValue(false, forKey: "displaying")
        }
        
        let object = context.object(with: objectID)
        object.setValue(true, forKey: "displaying") // 전달받은 것만 true로 바꿈
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func editCatalogName(_ objectID: NSManagedObjectID, name: String) -> Bool {
        let object = context.object(with: objectID)
        object.setValue(name, forKey: "name")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
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
