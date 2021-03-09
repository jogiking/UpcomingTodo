//
//  TodoDetailViewController.swift
//  Todo
//
//  Created by turu on 2021/03/09.
//

import UIKit

class TodoDetailViewController: UIViewController {

    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.delegate = self
//        tableView.dataSource = self
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
    }
    @IBAction func cancelAction(_ sender: Any) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

