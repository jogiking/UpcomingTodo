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
    
    @IBOutlet weak var todayCardView: CardBoardView!
    @IBOutlet weak var upcomingCardView: CardBoardView!
    @IBOutlet weak var totalCardView: CardBoardView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        
        navItem.searchController = searchController
        navItem.hidesSearchBarWhenScrolling = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        
        setupCardViews()
    }
    
    func setupCardViews() {
        todayCardView.title.text = "오늘"
        upcomingCardView.title.text = "예정"
        totalCardView.title.text = "전체"
        
        totalCardView.countTitle.text = "0" // 여기서 쿼리 fetch가 필요함
        
    }
}

extension MainPageViewController: UITableViewDelegate {
    
}

extension MainPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell",for:  indexPath)
        cell.backgroundColor = .lightGray
        
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
