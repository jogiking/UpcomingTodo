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
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var editModePickerView: UIPickerView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var dao = TodoDAO()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var pickerDataList = self.dao.fetchUpcomingTodoList()
    var pickerViewSelectedRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        
        upcomingStackView.layer.cornerRadius = 20
        upcomingStackView.clipsToBounds = true
        
        editModePickerView.delegate = self
        editModePickerView.dataSource = self
        
        scrollView.delegate = self
        
        navigationChange()
    }
    
    func navigationChange() {
        self.navigationController?.navigationBar.prefersLargeTitles = true

        let navigationBarAppearance = UINavigationBarAppearance()
//
//        navigationBarAppearance.titleTextAttributes = [
//            .font: UIFont.systemFont(ofSize: 30)
//        ]
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        self.navigationController?.navigationBar.tintColor = UIColor.appColor(.systemButtonTintColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in MainVC")
        updateMainPage()
        
        updateNavigationTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in MainVC")
        
        if let upcomingView = upcomingStackView.arrangedSubviews[1] as? UpcomingView {
            upcomingView.onTimerStop()
        }
        
        
        self.navigationItem.title = "Back".localized
    }
    
    func updateNavigationTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        switch dateFormatter.locale.languageCode {
        case "ko":
            dateFormatter.dateFormat = "M월 d일, EEEE"
        default: // en
            dateFormatter.dateFormat = "EEEE, MMM d"
        }
        
        let dateString = dateFormatter.string(from: Date())
        self.navigationItem.title = dateString
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationController = self.navigationController else { return }
        let threshold = navigationController.navigationBar.frame.height
        print("threshold = \(threshold)")
        let alpha = scrollView.contentOffset.y / threshold
        navigationController.navigationBar.subviews.first?.alpha = alpha
        
        updateNavigationTitle()

        print("didScroll] \(scrollView.contentOffset.y)")
    }
    
    func updateMainPage() {
        appDelegate.myData = self.dao.fetch()
        navItem.rightBarButtonItem?.isEnabled = appDelegate.myData.count > 0
        
        setupCardViews()
        setupUpcomingView()
        
        updatePickerView()
        
        tableView.invalidateIntrinsicContentSize()
        self.tableView.reloadData()
    }
    
    func updatePickerView() {
        self.pickerDataList = self.dao.fetchUpcomingTodoList()
        editModePickerView.isHidden = !(tableView.isEditing && (pickerDataList.count > 0))
        
        // pickerDataList중에서 displaying == true인 것을 가장 앞으로 보낸다.
        for (i, item) in pickerDataList.enumerated() {
            if item.displaying! { // 맨 앞으로 보낸다
                let temp = pickerDataList.remove(at: i)
                pickerDataList.insert(temp, at: 0)
                break
            }
        }
        
        self.pickerViewSelectedRow = 0
        self.editModePickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    func setupUpcomingView() {
        let dataList = self.dao.fetchUpcomingTodoList()
        guard dataList.isEmpty == false else { // warningView 구성하기
            print("setupUpcomingView] No Upcoming Data.")
            let upcomingView = upcomingStackView.arrangedSubviews[1] as! UpcomingView
            let warningView = upcomingStackView.arrangedSubviews[2]
            
            upcomingView.targetData = nil
            upcomingView.onTimerStop()
            
            UIView.animate(withDuration: 0.25) {
                warningView.isHidden = false
                warningView.alpha = 1
            }
            
            if upcomingView.isHidden == false {
                UIView.animate(withDuration: 0.25) {
                    upcomingView.isHidden = true
                    upcomingView.alpha = 0
                }
            }
            return
        }
        
        let displayingTodoDataList = dataList.filter { $0.displaying! }
        
        guard displayingTodoDataList.count < 2 else { // 오류 처리
            print("setupUpcomingView] Wrong Number Of displayingTodoData=\(displayingTodoDataList.count)")
            return
        }
        
        var data = dataList.first!
        if displayingTodoDataList.isEmpty { // 아직 displaying이 지정된 todoData가 없는 경우
             // 맨 앞에 있는 todoData
            guard self.dao.updateDisplayingAttribute(data.objectID!) else {
                print("setupUpcomingView] updateDisplayingAttribute error")
                return
            }
            
        } else {
            data = displayingTodoDataList.first!
        }
        
        // 맨 앞에 있는 todoData로 upcomingView를 구성
        print("setupUpcomingView] todoData=\(data.title)")
        let upcomingView = upcomingStackView.arrangedSubviews[1] as! UpcomingView
        let warningView = upcomingStackView.arrangedSubviews[2]
            
        UIView.animate(withDuration: 0.25) {
            upcomingView.isHidden = false
            upcomingView.alpha = 1
        }
            
        if warningView.isHidden == false {
            UIView.animate(withDuration: 0.25) {
                warningView.isHidden = true
                warningView.alpha = 0
            }
        }
            
        upcomingView.targetData = data
        upcomingView.upcomingViewTimerCallback()
        upcomingView.onTimerStart()
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
        totalCardView.title.text = "All".localized
        totalCardView.countTitle.text = "\(appDelegate.myData.count)"
        totalCardView.imgView.image = UIImage(systemName: "tray.fill")
        totalCardView.imgView.tintColor = .systemGray
        
        todayCardView.title.text = "Today".localized
        todayCardView.countTitle.text = "\(getNumberOfTodayDeadLine())"
        todayCardView.imgView.image = UIImage(systemName: "clock.fill")
        todayCardView.imgView.tintColor = .systemGray
    }
    
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        guard appDelegate.myData.count > 0 else {
            return
        }
        UIView.animate(withDuration: 0.35) { [self] in
            switch tableView.isEditing {
            case false: // edit중이아니었을 때
                for i in 0...mainStackView.arrangedSubviews.count - 3 {
                    let item = mainStackView.arrangedSubviews[i]
                    item.isHidden = true
                    item.alpha = 0
                }
                                
                tableView.isEditing = true
                sender.title = "Done".localized
                
                updatePickerView()
//                editModePickerView.isHidden = false
                
                self.navigationItem.largeTitleDisplayMode = .never
                
            case true: // edit중이었을 때
                for i in 0...mainStackView.arrangedSubviews.count - 3 {
                    let item = mainStackView.arrangedSubviews[i]
                    item.isHidden = false
                    item.alpha = 1
                }
                
                tableView.isEditing = false
                sender.title = "Edit".localized
                
//                editModePickerView.isHidden = true
                if editModePickerView.isHidden == false {
                    let row = self.pickerViewSelectedRow
                    print("selectedRow = \(row)")
                    let todoData = self.pickerDataList[row]
                    if dao.updateDisplayingAttribute(todoData.objectID!) {
                        print("pickerView displaying 갱신 성공.")
                        updateMainPage()// 선택한 데이터를 targetData로 다시 upcomingView를 재구성해야한다.
                    } else {
                        print("pickerView displaying 갱신 실패")
                    }
                }
                
                updatePickerView()
                
                self.navigationItem.largeTitleDisplayMode = .always
                
            }
        }
    }
    
    @IBAction func addCatalog(_ sender: Any) {
        let alertController = UIAlertController(title: "New List".localized, message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (save) in
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
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive) { (_) in
            print("취소 눌림")
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        
        alertController.addTextField { (tf) in
            tf.borderStyle = .none
            tf.placeholder = "Input List Name".localized
            
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
