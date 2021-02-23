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
    
    
    
    // fetch
    // save
    // delete
}
