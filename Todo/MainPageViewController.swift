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
    @IBOutlet weak var totalCardView: CardBoardView!
    
    @IBOutlet weak var upcomingView: UIView!
//    @IBOutlet weak var upcomingSubView: UpcomingView!
    
    @IBOutlet weak var upcomingSubView: UIView!
    
    lazy var dao = TodoDAO()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
//        tableView.estimatedRowHeight = 100
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear in MainVC")
        updateMainPage()
    }
    
    func updateMainPage() {
        appDelegate.myData = self.dao.fetch()
        setupCardViews()
        setupUpcomingView()
        
        tableView.invalidateIntrinsicContentSize()
        self.tableView.reloadData()
    }

    
    func setupUpcomingView() {
        upcomingView.layer.cornerRadius = 20
        upcomingView.clipsToBounds = true

        // 조건에 맞는 데이터 fetch를 해야한다.
        if let data = self.dao.fetchUpcomingTodo() {
            // 보여줄 todo가 존재 할 때
            print("setupUpcomingView] todoData=\(data.title)")
            let view = UpcomingView()
            view.updateContent(data: data)
            view.frame = upcomingSubView.bounds
            upcomingSubView.addSubview(view)
        } else {
            // deadline todo가 하나도 없을 때
            print("setupUpcomingView] no deadline data")
            // 이때 없다는 새로운 뷰를 만들어서 넣어줘야함....
        }

    }

       
    func setupCardViews() {
        totalCardView.title.text = "전체"
        todayCardView.title.text = "오늘"
        totalCardView.countTitle.text = "\(appDelegate.myData.count)"
//            {
//            var count = 0
//            for _ in appDelegate.myData {
//                //count += catalog.todoList.count
//
//                count += 1
//            }
//            let countText = "\(count)"
//            return countText
//        }()
    }
    
    @IBAction func addCatalog(_ sender: Any) {
        let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let addCatalogVC = storyboard?.instantiateViewController(identifier: "addCatalogVC") else {
            return
        }
        
        addCatalogVC.modalPresentationStyle = .pageSheet
        present(addCatalogVC, animated: true)
    }
    
}

extension MainPageViewController: UITableViewDelegate {
}

extension MainPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let catalog = appDelegate.myData[indexPath.row]
            if dao.delete(catalog.objectID!) {
                appDelegate.myData.remove(at: indexPath.row)
                dao.updateDisplayOrder(removeCatalogIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                updateMainPage()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let todoListVC = self.storyboard?.instantiateViewController(identifier: "todoListVC") as? TodoListViewController else {
            return
        }
        
        let row = indexPath.row
//        todoListVC.mainTitleText = self.appDelegate.myData[row].name!
//        todoListVC.todoList = self.appDelegate.myData[row].todoList
//        todoListVC.catalogObjectID = self.appDelegate.myData[row].objectID
        todoListVC.currentCatalogData = self.appDelegate.myData[row]
        
        self.navigationController?.pushViewController(todoListVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRowAt. name = \(appDelegate.myData[indexPath.row].name)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell",for: indexPath)
        
        cell.textLabel?.text = appDelegate.myData[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        let detailNumber = "\(appDelegate.myData[indexPath.row].todoList.count)"
        cell.detailTextLabel?.text = detailNumber
        cell.backgroundColor = .white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("numberOfRowInSection : \(appDelegate.myData.count)")
        return appDelegate.myData.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension UITableView {
    open override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
//    open override var contentSize: CGSize {
//            didSet {
//                invalidateIntrinsicContentSize()
//            }
//        }
//
//    open override var intrinsicContentSize: CGSize {
//            layoutIfNeeded()
//            return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
//        }

}
