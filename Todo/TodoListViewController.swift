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
                changeCompletionBtnImage()
            }
        }
    }
    var todoList: [TodoData] = []
    
    var indexOfCatalog: Int!
    var currentCatalogData: CatalogData?
    var startIndexPath: IndexPath?
    
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
            tableView.setBottomInset(to: keyboardHeight - view.safeAreaInsets.bottom)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        tableView.setBottomInset(to: 0.0)
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
        
//        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.keyboardDismissMode = .interactive
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "BasicCell", bundle: nil), forCellReuseIdentifier: "basicCell")
        tableView.register(UINib(nibName: "MemoCell", bundle: nil), forCellReuseIdentifier: "memoCell")
        
        let tableViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTouch(_:)))
        tableView.addGestureRecognizer(tableViewGestureRecognizer)
        
        completeButton.title = "완료"
        completeButton.isEnabled = false
                
    }
    
    @objc func tableViewTouch(_ sender: Any) {
        switch editingStatus.isEditingMode {
        case true:
            editingStatus.textView?.resignFirstResponder()
        case false:
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
    
    func textEditingFinish() {
        guard editingStatus.isEditingMode else { return }
        guard let cell = editingStatus.cell else { return }
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let indexPath = editingStatus.indexPath else {
            return
        }
        
        guard editingStatus.textView?.text.isEmpty == false else {
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
            editTodo.title = editingStatus.textView!.text
        } else {
            let editTodo = todoList[indexPath.section]
            editTodo.title = editingStatus.textView!.text
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
                            editingStatus.textView?.text = "새로운 할 일"
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
         DispatchQueue.main.async {
            let lastRowInLastSection = 0
            let lastSection = self.todoList.count - 1
            let indexPath = IndexPath(row: lastRowInLastSection, section: lastSection)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.todoList.count - 1)) as? BasicCell {
//                guard let tv = cell.title else {
//                    print("왜안나오지")
//                    return
//
//                }
//                print("무조건 나와야함")
//                tv.becomeFirstResponder()
//            }
         }
    }
    
    func changeCompletionBtnImage() {
        if editingStatus.isEditingMode {
//            completeButton.image = nil
            completeButton.isEnabled = true
        } else {
//            completeButton.image = UIImage(systemName: "ellipsis.circle")
            completeButton.isEnabled = false
        }
    }

    @IBAction func addTodo(_ sender: Any) {
        self.todoList.append(TodoData())
        tableView.insertSections(IndexSet(integer: todoList.count - 1), with: .bottom)
        
        scrollToBottom()
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.todoList.count - 1)) as? BasicCell {
            guard let tv = cell.title else { return }
            tv.becomeFirstResponder()
        }
    }
}

extension TodoListViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 해당하는 셀의 btn 이미지를 바꿔야한다(생기는거로)
        print("textViewDidBeginEditing")
        
        if let cell = textView.superview?.superview as? DynamicCellProtocol {
            cell.shrinkAccessory(false)
            cell.changeBtnStatusImage(statusType: .InfoCircle)
            
            editingStatus = (true, cell as? UITableViewCell, textView, tableView.indexPath(for: cell as! UITableViewCell))
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEtiting] \(textView.text)")
        textEditingFinish()
        
        if editingStatus.isEditingMode {
            editingStatus = (false, nil, nil, nil)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        print("textViewDidChange] estimatedSize=\(estimatedSize), frame=\(textView.frame)")
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if constraint.constant != estimatedSize.height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
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

extension TodoListViewController: UITableViewDelegate,
                                  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfCell = 1
        let todo = todoList[section]
        
        if todo.isOpen == true {
            numberOfCell += todo.subTodoList.count
        }
        
        return numberOfCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        guard let date = todoList[section].deadline else { return nil }
        let dateString = dateFomatter.string(from: date)
        return "\(dateString)까지"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = tableView.backgroundColor
        header.textLabel?.textColor = .systemBlue
    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return section == todoList.count - 1 ? 0 : 1
//    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        print("delete?? section: \(indexPath.section), row : \(indexPath.row)")
        if editingStyle == .delete {
            // commit위치가 빈셀의 바로 위일때만 빈셀의 지워짐도 같이처리됨
            if indexPath.row == 0 {
                todoList.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                todoList[indexPath.section].subTodoList.remove(at: indexPath.row - 1)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                //현재 indexPath가 isEdidtingMode인 셀이 아니라면 업데이트
                if editingStatus.isEditingMode {
                    let isEditingParentCell = tableView.indexPath(for: editingStatus.cell!) != IndexPath(row: 0, section: indexPath.section)
                    editingStatus.textView?.resignFirstResponder()
                    if isEditingParentCell {
                        tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .automatic)
                    }
                } else {
                    tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .automatic)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if hasMemo(indexPath: indexPath) {
            cell = setupMemoCell(indexPath: indexPath)
        } else {
            cell = setupBasicCell(indexPath: indexPath)
        }
        
        return cell
    }
    
    func setupMemoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! MemoCell
        cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
        cell.btn.isUserInteractionEnabled = true
        cell.selectImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSelectImage(_:))))
        cell.selectImg.isUserInteractionEnabled = true
        
        if indexPath.row == 0 { // main cell
            let mainTodo = todoList[indexPath.section]
            cell.changeSelectImg(isFinish: mainTodo.isFinish!)
            cell.title.text = mainTodo.title
            cell.title.delegate = self
            cell.memo.text = mainTodo.memo
            cell.memo.delegate = self
            
            if mainTodo.numberOfSubTodo > 0 {
                cell.btn.image = mainTodo.isOpen! ? UIImage(named: "disclosure_open") : UIImage(named: "disclosure_close")
                cell.btn.tag = indexPath.section

                cell.childNumber.text = mainTodo.isOpen! ? "" : String(todoList[indexPath.section].numberOfSubTodo)
                
                cell.shrinkAccessory(false) // constraint 설정, not shrink
            } else { // shrink
                cell.shrinkAccessory(true)
            }
        
            cell.indentLeading(false) // indent 설정
        
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            cell.changeSelectImg(isFinish: subTodo.isFinish!)
            cell.title.text = subTodo.title
            cell.title.delegate = self
            cell.memo.text = subTodo.memo
            cell.memo.delegate = self
            
            cell.shrinkAccessory(true)
            cell.indentLeading(true) // indent 설정
        }
        
        return cell
    }
    
    func setupBasicCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicCell
        cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
        cell.btn.isUserInteractionEnabled = true
        cell.selectImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSelectImage(_:))))
        cell.selectImg.isUserInteractionEnabled = true
    
        if indexPath.row == 0 { // main cell
            let mainTodo = todoList[indexPath.section]
            cell.changeSelectImg(isFinish: mainTodo.isFinish!)
            cell.title.text = mainTodo.title
            cell.title.delegate = self
            
            if mainTodo.numberOfSubTodo > 0 {
                cell.btn.image = mainTodo.isOpen! ? UIImage(named: "disclosure_open") : UIImage(named: "disclosure_close")
                cell.btn.tag = indexPath.section

                cell.childNumber.text = mainTodo.isOpen! ? "" : String(todoList[indexPath.section].numberOfSubTodo)
                cell.shrinkAccessory(false) // constraint 설정, not shrink
            } else { // shrink
                cell.shrinkAccessory(true)
            }
        
            cell.indentLeading(false) // indent 설정
        
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            cell.changeSelectImg(isFinish: subTodo.isFinish!)
            cell.title.text = subTodo.title
            cell.title.delegate = self
            
            cell.shrinkAccessory(true)
            cell.indentLeading(true) // indent 설정
        }
        
        return cell
    }
}

extension TodoListViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print("itemsForBeginning] \(indexPath)")
        if editingStatus.isEditingMode {
            editingStatus.textView?.text = "새로운 할 일"
            editingStatus.textView?.resignFirstResponder()
        }
        self.startIndexPath = indexPath
        
        let section = indexPath.section
        if (indexPath.row == 0) && todoList[section].isOpen! {
            todoList[section].isOpen = false
            tableView.reloadSections(IndexSet(section...section), with: .none)
        }
        
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        self.completeButton.isEnabled = false
        self.addTodoButton.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        self.completeButton.isEnabled = true
        self.addTodoButton.isEnabled = true
    }
    
}

extension TodoListViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {

        switch coordinator.proposal.intent {
        case .insertAtDestinationIndexPath:
            if coordinator.proposal.operation == .move {
                updateInsertAtDatasource(destinationIndexPath: coordinator.destinationIndexPath!)
                tableView.reloadData()
            }
        case .insertIntoDestinationIndexPath:
            updateInsertIntoDatasource(destinationIndexPath: coordinator.destinationIndexPath!)
            tableView.reloadData()
            
        default:
            ()
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        //        print("dropSession] section=\(destinationIndexPath?.section), row=\(destinationIndexPath?.row)")
        
        var dropProposal = UITableViewDropProposal(operation: .cancel)
        
        // Accept only one drag item.
        guard session.items.count == 1 else { return dropProposal }
        
        guard session.localDragSession != nil else {
            return dropProposal
        }
        guard let source = startIndexPath, let destination = destinationIndexPath else {
            return dropProposal
        }
        
        guard isPc(sourceIndexPath: source) || isC(sourceIndexPath: destination) else {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .automatic)
            return dropProposal
        }
        
        if isPc(sourceIndexPath: source) && isC(sourceIndexPath: destination) {
            dropProposal = UITableViewDropProposal(operation: .forbidden)
        } else {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return dropProposal
    }
    
    func isP(sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.row == 0 else { return false }
        if todoList[sourceIndexPath.section].numberOfSubTodo == 0 {
            return true
        }
        return false
    }
    
    func isPc(sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.row == 0 else { return false }
        if todoList[sourceIndexPath.section].numberOfSubTodo == 0 {
            return false
        }
        return true
    }
    
    func isC(sourceIndexPath: IndexPath) -> Bool {
        return sourceIndexPath.row != 0 ? true : false
    }
    
    func isLastDestination(destinationPath: IndexPath) -> Bool {
        if (destinationPath.section == todoList.count - 1) {
            var lastRow = todoList.last!.isOpen == true ? todoList.last!.numberOfSubTodo : 0
            lastRow += 1
            
            if (destinationPath.row == lastRow) {
                return true
            }
        }
        return false
    }
    
    func updateInsertAtDatasource(destinationIndexPath: IndexPath) {
        let sourceIndexPath = self.startIndexPath!
        
        if !isC(sourceIndexPath: sourceIndexPath) { // P, Pc
            guard !isLastDestination(destinationPath: destinationIndexPath) else { // 마지막 셀이 아닐 때
                let data = todoList.remove(at: sourceIndexPath.section) // 마지막 셀일 때
                todoList.append(data)
                return
            }
            
            if isP(sourceIndexPath: sourceIndexPath) && (destinationIndexPath.row != 0) { // x섹션의 y위치로 삽입
                guard isC(sourceIndexPath: destinationIndexPath) && todoList[destinationIndexPath.section].isOpen! else {
                    let data = todoList.remove(at: sourceIndexPath.section) // x섹션 그 자리에 삽입
                    var toSection = destinationIndexPath.section
                    if sourceIndexPath.section > destinationIndexPath.section { toSection += 1 }
                    todoList.insert(data, at: toSection)
                    return
                }
                // x섹션의 y 위치로 삽입
                let data = todoList[sourceIndexPath.section]
                todoList[destinationIndexPath.section].subTodoList.insert(data, at: destinationIndexPath.row - 1)
                todoList.remove(at: sourceIndexPath.section)
            } else { // x섹션 그자리에 삽입
                let data = todoList.remove(at: sourceIndexPath.section)
                var toSection = destinationIndexPath.section
                if (sourceIndexPath.section < destinationIndexPath.section) && (destinationIndexPath.row == 0) { // ㄱ
                    toSection -= 1
                }
                if (sourceIndexPath.section > destinationIndexPath.section) && (destinationIndexPath.row != 0) { // ㄴ
                    toSection += 1
                }
                todoList.insert(data, at: toSection)
            }
        } else { // C(child)
            guard !isLastDestination(destinationPath: destinationIndexPath) else {
                let data = todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
                let tododata = TodoData()
                tododata.title = data.title
                tododata.memo = data.memo
                tododata.isFinish = data.isFinish
                tododata.objectID = data.objectID
                tododata.regDate = data.regDate
                todoList.append(tododata)
                return
            }
            if destinationIndexPath.row != 0 { // A. x섹션의 y위치로 삽입 (subs)
                guard isC(sourceIndexPath: destinationIndexPath) && todoList[destinationIndexPath.section].isOpen! else {
                    let data = todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
                    let tododata = TodoData()
                    tododata.title = data.title
                    tododata.memo = data.memo
                    tododata.isFinish = data.isFinish
                    tododata.objectID = data.objectID
                    tododata.regDate = data.regDate
                    todoList.insert(tododata, at: destinationIndexPath.section)
                    return
                }
                let data = todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
                todoList[destinationIndexPath.section].subTodoList.insert(data, at: destinationIndexPath.row - 1)
            } else { // B. x섹션의 p로 삽입(타입 변환)
                let data = todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
                let tododata = TodoData()
                tododata.title = data.title
                tododata.memo = data.memo
                tododata.isFinish = data.isFinish
                tododata.objectID = data.objectID
                tododata.regDate = data.regDate
                todoList.insert(tododata, at: destinationIndexPath.section)
            }
        }
    }
    
    func updateInsertIntoDatasource(destinationIndexPath: IndexPath) {
        let sourceIndexPath = self.startIndexPath!
        if isP(sourceIndexPath: sourceIndexPath) {
            let todo = todoList[sourceIndexPath.section]
            let subs = Todo()
            subs.title = todo.title
            subs.memo = todo.memo
            subs.isFinish = todo.isFinish
            subs.regDate = todo.regDate

            todoList[destinationIndexPath.section].subTodoList.append(subs)
            todoList[destinationIndexPath.section].isOpen = true
            todoList.remove(at: sourceIndexPath.section)
            
        } else { // isC
            guard sourceIndexPath.section != destinationIndexPath.section else { return }
            let subs = todoList[sourceIndexPath.section].subTodoList[sourceIndexPath.row - 1]
            let newSubs = Todo()
            newSubs.title = subs.title
            newSubs.memo = subs.memo
            newSubs.isFinish = subs.isFinish
            newSubs.regDate = subs.regDate

            todoList[destinationIndexPath.section].subTodoList.append(newSubs)
            todoList[destinationIndexPath.section].isOpen = true
            todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
        }
    }
}

extension UITableView {

    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}
