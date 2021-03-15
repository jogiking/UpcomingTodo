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
    
    @IBOutlet weak var upcomingStackView: UIStackView!
    @IBOutlet weak var expandingUpcomingButton: UIButton!
    
    lazy var dao = TodoDAO()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        
        upcomingStackView.layer.cornerRadius = 20
        upcomingStackView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in MainVC")
        updateMainPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in MainVC")
        
        if let upcomingView = upcomingStackView.arrangedSubviews[1] as? UpcomingView {
            upcomingView.onTimerStop()
        }
    }
    
    func updateMainPage() {
        appDelegate.myData = self.dao.fetch()
        setupCardViews()
        setupUpcomingView()
                
        tableView.invalidateIntrinsicContentSize()
        self.tableView.reloadData()
    }
    
    func setupUpcomingView() {
        if let data = self.dao.fetchUpcomingTodo() {
            // 보여줄 todo가 존재 할 때
            print("setupUpcomingView] todoData=\(data.title)")
            let upcomingView = upcomingStackView.arrangedSubviews[1] as! UpcomingView
            let warningView = upcomingStackView.arrangedSubviews[2]
              
            upcomingView.isHidden = false
            expandingUpcomingButton.isEnabled = true
            expandingUpcomingButton.tintColor = .systemBlue
            
            if warningView.isHidden == false {
                UIView.animate(withDuration: 0.25) {
                    warningView.isHidden = true
                    
                }
            }
            
            upcomingView.targetData = data
            upcomingView.onTimerStart()
        } else {
            print("setupUpcomingView] no deadline data")
            let upcomingView = upcomingStackView.arrangedSubviews[1] as! UpcomingView
            let warningView = upcomingStackView.arrangedSubviews[2]
            
            upcomingView.targetData = nil
            upcomingView.onTimerStop()
            
            warningView.isHidden = false
            expandingUpcomingButton.isEnabled = false
            expandingUpcomingButton.tintColor = .systemGray
            
            if upcomingView.isHidden == false {
                UIView.animate(withDuration: 0.25) {
                    upcomingView.isHidden = true
                }
            }
        }
    }

    func getYearMonthDayString(date: Date) -> String {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFomatter.string(from: date)
        return dateString
    }
    
    func getNumberOfTodayDeadLine() -> Int {
        var numberOfTodayDeadline = 0
        let today = getYearMonthDayString(date: Date())
        for catalog in appDelegate.myData {
            for todo in catalog.todoList {
                if let todoDeadline = todo.deadline {
                    let todoDeadlineString = getYearMonthDayString(date: todoDeadline)
                    if today == todoDeadlineString {
                        numberOfTodayDeadline += 1
                    }
                }
            }
        }
        
        return numberOfTodayDeadline
    }
       
    func setupCardViews() {
        totalCardView.title.text = "전체"
        totalCardView.countTitle.text = "\(appDelegate.myData.count)"
        totalCardView.imgView.image = UIImage(systemName: "tray")
        totalCardView.imgView.tintColor = .systemGray
        
        todayCardView.title.text = "오늘"
        todayCardView.countTitle.text = "\(getNumberOfTodayDeadLine())"
        todayCardView.imgView.image = UIImage(systemName: "clock")
        todayCardView.imgView.tintColor = .systemGray
        
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
    
    @IBAction func showFullScreen(_ sender: Any) {
        guard let upcomingView = upcomingStackView.arrangedSubviews[1] as? UpcomingView else { return }
        guard let fullScreenVC = self.storyboard?.instantiateViewController(withIdentifier: "fullscreenVC") as? FullScreenViewController else { return }
 
        fullScreenVC.modalTransitionStyle = .coverVertical
        fullScreenVC.modalPresentationStyle = .fullScreen
        fullScreenVC.targetData = upcomingView.targetData

        self.present(fullScreenVC, animated: true, completion: nil)
    }
    
    @objc func addAlertTextFieldDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction func addCatalog(_ sender: Any) {
        
//        let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: Bundle.main)
//        guard let addCatalogVC = storyboard?.instantiateViewController(identifier: "addCatalogVC") else {
//            return
//        }
//
//        addCatalogVC.modalPresentationStyle = .pageSheet
//        present(addCatalogVC, animated: true)
        
        let alertController = UIAlertController(title: "새로운 목록", message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "확인", style: .default, handler: { (save) in
            print("확인 눌림")
            
            let data = CatalogData()
            data.name = alertController.textFields?.first?.text
            data.regDate = Date()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            data.displayOrder = appDelegate.myData.count
            self.dao.insert(data)
            
            self.updateMainPage()
            
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive) { (_) in
            print("취소 눌림")
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        
        alertController.addTextField { (tf) in
            tf.borderStyle = .none
            tf.placeholder = "목록 이름을 입력"
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: tf, queue: .main) { (_) in
                let textCount = tf.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                
                okAction.isEnabled = textIsNotEmpty
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
            
        okAction.isEnabled = false
        
        
        self.present(alertController, animated: true)
    }
    
}


extension MainPageViewController: UITableViewDelegate, UITableViewDataSource {
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
        print("MainPageVC+didSelectRowAt] indexPath=\(indexPath.row)")
        guard let todoListVC = self.storyboard?.instantiateViewController(identifier: "todoListVC") as? TodoListViewController else {
            return
        }
        
        todoListVC.indexOfCatalog = indexPath.row
        
        self.navigationController?.pushViewController(todoListVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell",for: indexPath)
        cell.textLabel?.text = appDelegate.myData[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        let detailNumber = "\(appDelegate.myData[indexPath.row].todoList.count)"
        cell.detailTextLabel?.text = detailNumber
        
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
