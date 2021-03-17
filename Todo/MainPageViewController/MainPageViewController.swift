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
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    
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
        navItem.rightBarButtonItem?.isEnabled = appDelegate.myData.count > 0
        
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
            
            UIView.animate(withDuration: 0.25) {
                upcomingView.isHidden = false
                upcomingView.alpha = 1
            }
            
            expandingUpcomingButton.isEnabled = true
            expandingUpcomingButton.tintColor = .systemBlue
            
            if warningView.isHidden == false {
                UIView.animate(withDuration: 0.25) {
                    warningView.isHidden = true
                    warningView.alpha = 0
                }
            }

            upcomingView.targetData = data
            upcomingView.upcomingViewTimerCallback()
            upcomingView.onTimerStart()
            
        } else {
            print("setupUpcomingView] no deadline data")
            let upcomingView = upcomingStackView.arrangedSubviews[1] as! UpcomingView
            let warningView = upcomingStackView.arrangedSubviews[2]
            
            upcomingView.targetData = nil
            upcomingView.onTimerStop()
            
            UIView.animate(withDuration: 0.25) {
                warningView.isHidden = false
                warningView.alpha = 1
            }
            
            expandingUpcomingButton.isEnabled = false
            expandingUpcomingButton.tintColor = .systemGray
            
            if upcomingView.isHidden == false {
                UIView.animate(withDuration: 0.25) {
                    upcomingView.isHidden = true
                    upcomingView.alpha = 0
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
        totalCardView.imgView.image = UIImage(systemName: "tray.fill")
        totalCardView.imgView.tintColor = .systemGray
        
        todayCardView.title.text = "오늘"
        todayCardView.countTitle.text = "\(getNumberOfTodayDeadLine())"
        todayCardView.imgView.image = UIImage(systemName: "clock.fill")
        todayCardView.imgView.tintColor = .systemGray
    }
    
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
//        print((sender as! UIBarButtonItem).description)
        
        guard appDelegate.myData.count > 0 else {
            return
        }
        
        switch tableView.isEditing {
        case false:
            tableView.isEditing = true
            for item in mainStackView.arrangedSubviews {
                if item == mainStackView.arrangedSubviews.last { continue }
                
                UIView.animate(withDuration: 0.35) {
                    item.isHidden = true
                    item.alpha = 0
                }
            }
            sender.title = "완료"
            
        case true:
            tableView.isEditing = false
            for item in mainStackView.arrangedSubviews {
                if item == mainStackView.arrangedSubviews.last { continue }
                UIView.animate(withDuration: 0.35) {
                    item.isHidden = false
                    item.alpha = 1
                }
            }
            sender.title = "편집"
            
        }
    }
    
    @IBAction func showFullScreen(_ sender: Any) {
        guard let upcomingView = upcomingStackView.arrangedSubviews[1] as? UpcomingView else { return }
        guard let fullScreenVC = self.storyboard?.instantiateViewController(withIdentifier: "fullscreenVC") as? FullScreenViewController else { return }
 
        fullScreenVC.modalTransitionStyle = .coverVertical
        fullScreenVC.modalPresentationStyle = .fullScreen
        fullScreenVC.targetData = upcomingView.targetData

        self.present(fullScreenVC, animated: true, completion: nil)
    }
    
    @IBAction func addCatalog(_ sender: Any) {
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
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        navItem.rightBarButtonItem?.title = "완료"
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        navItem.rightBarButtonItem?.title = "편집"
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let data = appDelegate.myData.remove(at: sourceIndexPath.row)
        appDelegate.myData.insert(data, at: destinationIndexPath.row)
        
        self.dao.updateDisplayOrder() // 순서 동기화
    }
       
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("in delete")
        if editingStyle == .delete {
            
            let catalog = appDelegate.myData[indexPath.row]
            if dao.delete(catalog.objectID!) {
                appDelegate.myData.remove(at: indexPath.row)
                dao.updateDisplayOrder(removeCatalogIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                updateMainPage()
                
                if appDelegate.myData.count < 1 {
                    DispatchQueue.main.async {
                        tableView.isEditing = false
                        
                        for item in self.mainStackView.arrangedSubviews {
                            if item == self.mainStackView.arrangedSubviews.last { continue }
                            UIView.animate(withDuration: 0.35) {
                                item.isHidden = false
                                item.alpha = 1
                            }
                        }
                        self.navItem.rightBarButtonItem?.title = "편집"
                    }
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("accessory touched in \(indexPath.row)")
        
        let alertController = UIAlertController(title: "목록 이름 수정", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { (save) in
            print("확인 눌림")
            // 현재 들어있는 텍스트가 카탈로그 이름으로 저장된다.
            guard let text = alertController.textFields?.first?.text else { return }
            guard text != self.appDelegate.myData[indexPath.row].name else { return }
            
            // coredata 갱신
            if self.dao.editCatalogName(self.appDelegate.myData[indexPath.row].objectID!, name: text) {
                // 갱신 성공시 로컬 배열에 저장함
                self.appDelegate.myData[indexPath.row].name = text
                self.updateMainPage()
                print("이름 변경 성공!")
            }
            
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .destructive) { (_) in
            print("취소 눌림")
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        
        alertController.addTextField { (tf) in
            tf.borderStyle = .none
            tf.text = self.appDelegate.myData[indexPath.row].name
            tf.placeholder = self.appDelegate.myData[indexPath.row].name
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: tf, queue: .main) { (_) in
                let textCount = tf.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                
                okAction.isEnabled = textIsNotEmpty
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
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
