//
//  TodoListViewController.swift
//  Todo
//
//  Created by turu on 2021/02/25.
//
import UIKit
import CoreData

class TodoListViewController: UIViewController, TodoDetailViewControllerDelegate {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: UIBarButtonItem!
    @IBOutlet weak var addTodoButton: UIBarButtonItem!
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var dao = TodoDAO()
        
    var editingStatus: (isEditingMode: Bool, cell: UITableViewCell?, textView: UITextView?, indexPath: IndexPath?) = (false, nil, nil, nil) {
        didSet(oldValue) {
            if oldValue.isEditingMode != editingStatus.isEditingMode {
                changeCompletionBtnImage() // 네비게이션 우측 상단 버튼
            }
        }
    }
    
    var todoList: [TodoData] = []
    
    var indexOfCatalog: Int!
    var currentCatalogData: CatalogData?
    var startIndexPath: IndexPath?
    
    var textViewHeight: CGFloat = 0.0
    
    override func viewWillLayoutSubviews() {
        print(" viewWillLayoutSubviews")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewwillappear")
        self.currentCatalogData = appDelegate.myData[indexOfCatalog]
        mainTitle.text = currentCatalogData?.name
        todoList = currentCatalogData!.todoList
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResign(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            
            print(keyboardHeight - view.safeAreaInsets.bottom + (tableView.tableFooterView?.frame.height)!)
            
            if let indexPath = editingStatus.indexPath {
                let rect = self.tableView.rectForRow(at: indexPath)
                let rectInScreen = self.tableView.convert(rect, to: tableView.superview)

                let bounds: CGRect = UIScreen.main.bounds
                
                print("keyboardWillShow] \(keyboardHeight), \(rectInScreen.minY), \(bounds.maxY)")
                if bounds.maxY - keyboardHeight < rectInScreen.maxY {
                    let inset = keyboardHeight - view.safeAreaInsets.bottom //+ (tableView.tableFooterView?.frame.height)!
                    tableView.setBottomInset(to: inset)
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: false)
                }
            }
            
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        tableView.setBottomInset(to: 0)
//        if editingStatus.isEditingMode {
//            editingStatus.textView?.resignFirstResponder()
//        }
    }
    
    @objc func willResign(_ sender: Any) {
        print("willResign")
        if editingStatus.isEditingMode {
            editingStatus.textView?.resignFirstResponder()
        }
        
        appDelegate.myData = self.dao.fetch()
        self.currentCatalogData = appDelegate.myData[indexOfCatalog]
        
        currentCatalogData?.todoList = todoList
        dao.saveCatalogContext(currentCatalogData!, discardingCatalogObjectID: (currentCatalogData?.objectID)!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        if editingStatus.isEditingMode {
            editingStatus.textView?.resignFirstResponder()
        }
        
        print("todoListVC will disappear. originID=\(appDelegate.myData[indexOfCatalog].objectID), currentID=\(currentCatalogData?.objectID)")
        
        appDelegate.myData = self.dao.fetch()
        self.currentCatalogData = appDelegate.myData[indexOfCatalog]
        
        currentCatalogData?.todoList = todoList
        dao.saveCatalogContext(currentCatalogData!, discardingCatalogObjectID: (currentCatalogData?.objectID)!)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.navigationController!.navigationBar.subviews.first?.alpha = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.keyboardDismissMode = .interactive
        
//        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "BasicCell", bundle: nil), forCellReuseIdentifier: "basicCell")
        tableView.register(UINib(nibName: "MemoCell", bundle: nil), forCellReuseIdentifier: "memoCell")
        
        let tableViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTouch(_:)))
        tableView.addGestureRecognizer(tableViewGestureRecognizer)
        
        completeButton.title = "Done".localized
        completeButton.isEnabled = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     
        guard let navigationController = self.navigationController else { return }
        let threshold = mainTitle.frame.height
        let alpha = scrollView.contentOffset.y / threshold
        navigationController.navigationBar.subviews.first?.alpha = alpha
        if alpha < 1  {
            UIView.animate(withDuration: 0.5) {
                self.navigationItem.title = ""
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.navigationItem.title = self.currentCatalogData?.name
            }
        }
        print("didScroll] \(scrollView.contentOffset.y)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("didEndScrolling]. \(tableView.isDragging)")
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.todoList.count - 1)) as? BasicCell {
            guard let tv = cell.title else { return }
            print("success becom")
            tv.becomeFirstResponder()
        } else {
            print("fail become")
        }
    }
    
    @objc func tableViewTouch(_ sender: Any) {
        switch editingStatus.isEditingMode {
        case true:
            editingStatus.textView?.resignFirstResponder()
        case false:
            print("footerFrame=\(tableView.tableFooterView?.frame)")
            addTodo(sender)
        }
    }
    
    func afterOp(indexPath: IndexPath) { // 해당 indexPath의 셀의 constraint들을 재조정해주는 메서드
        if let cell = tableView.cellForRow(at: indexPath) as? DynamicCellProtocol {
            guard !isPc(sourceIndexPath: indexPath) else {
                let isOpen = todoList[indexPath.section].isOpen!
                let statusType: TableViewCellRightButtonStatus = isOpen ? .DisclosureOpen : .DisclosureClose
                cell.changeBtnStatusImage(statusType: statusType)
                return
            }
            cell.shrinkAccessory(true) // p, c
        }
    }
    
    func updateEditingStatusIndexPath(at: IndexPath) {
        guard (editingStatus.indexPath! != at) else { return }
        
        if isC(sourceIndexPath: at) { // C
            if editingStatus.indexPath!.row > at.row {
                editingStatus.indexPath?.row -= 1
            }
        } else { // P, Pc
            if editingStatus.indexPath!.section > at.section {
                editingStatus.indexPath?.section -= 1
            }
        }
    }
    
    func textEditingFinish(_ indexPath: IndexPath, _ textView: UITextView) {
//        guard editingStatus.isEditingMode else { return }
//        guard let cell = editingStatus.cell else { return }
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
//        guard let indexPath = editingStatus.indexPath else {
//            return
//        }
        
        
        
        // tableView.indexPath(cell)로 indexPath를 구하게 된다면 스크롤 시 nil이 반환되는 경우가 발생한다
        // 그렇다고 indexPath를 저장해두고 쓰게되면 방금같은 상황에서 indexPath의 값이 틀리게된다...
        if textView.text.isEmpty {
            if isC(sourceIndexPath: indexPath) {
                todoList[indexPath.section].subTodoList.remove(at: indexPath.row - 1)
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                todoList.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
            return
        }
        
        if isC(sourceIndexPath: indexPath) {
            let editTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            editTodo.title = textView.text
        } else {
            let editTodo = todoList[indexPath.section]
            editTodo.title = textView.text
        }
        
        afterOp(indexPath: indexPath)
    }
    
    @IBAction func completionClick(_ sender: Any) {
//        textEditingFinish()
        if editingStatus.isEditingMode {
            editingStatus.textView?.resignFirstResponder()
        }
    }
    
    func hasMemo(indexPath: IndexPath) -> Bool {
        var hasMemo: Bool
        if indexPath.row == 0 { // main cell
            let todo = todoList[indexPath.section]
            hasMemo = todo.memo?.isEmpty == false ? true : false
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            hasMemo = subTodo.memo?.isEmpty == false ? true : false
        }
        
        return hasMemo
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "TodoDetailSegue":
            let navigationController = segue.destination as! UINavigationController
            let todoDetailViewController = navigationController.topViewController as! TodoDetailViewController
            
            navigationController.presentationController?.delegate = todoDetailViewController
            todoDetailViewController.delegate = self
            
            let data = sender as! (isParent: Bool, indexPath: IndexPath)
            todoDetailViewController.isParent = data.isParent
            todoDetailViewController.todoIndexPath = data.indexPath
            todoDetailViewController.todoList = self.todoList
        default:
            break
        }
    }
    
    @objc func tappedSelectImage(_ sender: Any) {
        print("tapped SelectImage")
        
        if let tgr = sender as? UITapGestureRecognizer {
            if let cell = tgr.view?.superview?.superview as? UITableViewCell {
                if let indexPath = tableView.indexPath(for: cell) {
                    let todo = isC(sourceIndexPath: indexPath) ?
                        todoList[indexPath.section].subTodoList[indexPath.row - 1] : todoList[indexPath.section]
                    
                    todo.isFinish = !(todo.isFinish!)
                    
                    (cell as? DynamicCellProtocol)?.changeSelectImg(isFinish: todo.isFinish!)
                }
            }
        }
    }
    
    @objc func tappedOpenImage(_ sender: Any) {
        print("tapped OpenImage")
        
        if editingStatus.isEditingMode {
            if let tgr = sender as? UITapGestureRecognizer {
                if let cell = tgr.view?.superview?.superview as? UITableViewCell {
                    if editingStatus.cell == cell {
                        // memoCell segue
                        print("go to memoCellSegue")
                        guard let indexPath = tableView.indexPath(for: editingStatus.cell!) else {
                            print("memoCell segue Index nil error")
                            return
                        }
                        
                        if editingStatus.textView?.text.isEmpty != false {
                            editingStatus.textView?.text = "New Todo".localized
                        }
                        editingStatus.textView?.resignFirstResponder()
                        
                        let isParent = indexPath.row == 0 ? true : false
                        let data = (isParent, indexPath)
                        
                        performSegue(withIdentifier: "TodoDetailSegue", sender: data)
                        
                    } else {
                        print("open/close기능에만 신경")
                        let section = (tableView.indexPath(for: cell)?.section)!
                        todoList[section].isOpen = !(todoList[section].isOpen!)
                        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                    }
                }
            }
            
        } else {
            if let tgr = sender as? UITapGestureRecognizer {
                let section = (tgr.view?.tag)!
                
                todoList[section].isOpen = !(todoList[section].isOpen!)
                tableView.reloadSections(IndexSet(integer: section), with: .automatic)
            }
        }
    }
    
    func scrollToBottom() {
        UIView.animate(withDuration: 0.25) {
            let lastRowInLastSection = 0
            let lastSection = self.todoList.count - 1
            let indexPath = IndexPath(row: lastRowInLastSection, section: lastSection)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        } completion: { (_) in
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.todoList.count - 1)) as? BasicCell {
                guard let tv = cell.title else { return }
                tv.becomeFirstResponder()
            }
        }
    }
    
    func changeCompletionBtnImage() {
        if editingStatus.isEditingMode {
//            completeButton.image = nil
            completeButton.isEnabled = true
            addTodoButton.isEnabled = false
        } else {
//            completeButton.image = UIImage(systemName: "ellipsis.circle")
            completeButton.isEnabled = false
            addTodoButton.isEnabled = true
        }
    }
    
    @IBAction func addTodo(_ sender: Any) {
        self.todoList.append(TodoData())
        tableView.performBatchUpdates {
            tableView.insertSections(IndexSet(integer: self.todoList.count - 1), with: .none)
        } completion: { (finished) in
            print("finishedAddTodo = \(finished)")
            let indexPath = IndexPath(row: 0, section: self.todoList.count - 1)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            
            if let indexPaths = self.tableView.indexPathsForVisibleRows {
                for item in indexPaths {
                    if item == indexPath {
                        let cell = (self.tableView.visibleCells.last!) as! BasicCell
                        cell.title.becomeFirstResponder()
                        break
                    }
                }
            }
                        
            self.addTodoButton.isEnabled = false
        }
    }
        
    // MARK: - TodoDetailViewControllerDelegate
    func todoDetailViewControllerDidFinish(_ todoDetailViewController: TodoDetailViewController) {
        // 콘텐츠 변경작업 수행
        guard let contents = todoDetailViewController.bringContents() else { return }
        let indexPath = todoDetailViewController.todoIndexPath!
        
        let isParentCell = todoDetailViewController.isParent
        let targetTodo = isParentCell ? todoList[indexPath.section] : todoList[indexPath.section].subTodoList[indexPath.row - 1]
    
        targetTodo.title = contents.title
        targetTodo.memo = contents.memo
        
    
        if isParentCell {
            if todoDetailViewController.deadline != (targetTodo as! TodoData).deadline {
                targetTodo.regDate = Date()
            }
            (targetTodo as! TodoData).deadline = todoDetailViewController.deadline
        }
        
        dismiss(animated: true) {
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
    
    func todoDetailViewControllerDidCancel(_ todoDetailViewController: TodoDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
}


extension UITableView {

    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}
