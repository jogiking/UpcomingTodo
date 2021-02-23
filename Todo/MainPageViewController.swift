//
//  MainPageViewController.swift
//  Todo
//
//  Created by turu on 2021/02/19.
//

import UIKit

class MainPageViewController: UIViewController {
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        
        navItem.searchController = searchController
        navItem.hidesSearchBarWhenScrolling = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
    }
}

extension MainPageViewController: UITableViewDelegate {
    
}

extension MainPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell",for:  indexPath)
        cell.backgroundColor = .blue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension UITableView {
    open override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
