//
//  TodoListViewController.swift
//  Todo
//
//  Created by turu on 2021/02/25.
//

import UIKit
import CoreData

class TodoListViewController: UIViewController {
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: UIBarButtonItem!
    @IBOutlet weak var addTodoButton: UIBarButtonItem!
    
    var dao = TodoDAO()
        
    var editingMode = false
    var todoList: [TodoData] = []
    var mainTitleText = ""
    var catalogObjectID: NSManagedObjectID?

    var startIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTitle.text = mainTitleText
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "BasicCell", bundle: nil), forCellReuseIdentifier: "basicCell")
        tableView.register(UINib(nibName: "MemoCell", bundle: nil), forCellReuseIdentifier: "memoCell")

        completeButton.image = UIImage(systemName: "ellipsis.circle")
        completeButton.title = "완료"
        
    }
    
    @IBAction func completionClick(_ sender: Any) {
       
        if editingMode == true {
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: todoList.count - 1)) as? BasicCell,
                  let tv = cell.title else { return }
            
            editingMode = false
            tv.resignFirstResponder()
            completeButton.image = UIImage(systemName: "ellipsis.circle")
            
            guard tv.text.isEmpty == false else {
                
                todoList.removeLast()
                tableView.deleteSections(IndexSet(integer: todoList.count), with: .fade)
                return
            }
            
            let lastTodo = todoList.last!
            lastTodo.title = tv.text
            lastTodo.regDate = Date()
            self.dao.insert(lastTodo, catalogObjectID: self.catalogObjectID!)
            
        }
    }
    
    @IBAction func updateView(_ sender: Any) {
        self.tableView.invalidateIntrinsicContentSize()
        self.tableView.reloadData()
    }
    
    func hasMemo(indexPath: IndexPath) -> Bool {
        var hasMemo: Bool
        if indexPath.row == 0 { // main cell
            let todo = todoList[indexPath.section]
            hasMemo = todo.memo == nil ? false : true
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            hasMemo = subTodo.memo == nil ? false : true
        }
        
        return hasMemo
    }
    
    @objc func tappedSelectImage(_ sender: Any) {
        print("tapped SelectImage")
    }

    @objc func tappedOpenImage(_ sender: Any) {
        print("tapped OpenImage")
        if let tgr = sender as? UITapGestureRecognizer {
            let section = (tgr.view?.tag)!
            
            todoList[section].isOpen = !(todoList[section].isOpen!)
            tableView.reloadSections(IndexSet(section...section), with: .none)
        }
    }
    
    func scrollToBottom() {
         DispatchQueue.main.async {
            let lastRowInLastSection = 0
            let lastSection = self.todoList.count - 1
            let indexPath = IndexPath(row: lastRowInLastSection, section: lastSection)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            
            
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.todoList.count - 1)) as? BasicCell {
                guard let tv = cell.title else {
                    print("왜안나오지")
                    return

                }
                print("무조건 나와야함")
                tv.becomeFirstResponder()
            }
         }
    }


    @IBAction func addTodo(_ sender: Any) {
        // 새로운 셀을 테이블에 추가만 한다.
        // 그리고 save누르면 그 셀이 저장이 되게
        
        self.todoList.append(TodoData())
        tableView.insertSections(IndexSet(integer: todoList.count - 1), with: .bottom)
        completeButton.image = nil
        editingMode = true
        
        scrollToBottom()
    }
    
}

extension TodoListViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // print(textView.text)
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        print("estimatedSize = \(estimatedSize)")
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
        }
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("delete?? section: \(indexPath.section), row : \(indexPath.row)")
        if editingStyle == .delete {
            if indexPath.row == 0 {
                todoList.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                tableView.reloadData()
                
            } else {
                todoList[indexPath.section].subTodoList.remove(at: indexPath.row - 1)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections(IndexSet(indexPath.section...indexPath.section), with: .fade)
            }
        
        }
    }
    
    func setupMemoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! MemoCell
           
        if indexPath.row == 0 { // main cell
            let mainTodo = todoList[indexPath.section]
            cell.selectImg.image = mainTodo.isFinish! ? UIImage(named: "click") : UIImage(named: "unclick")
            cell.selectImg.isUserInteractionEnabled = true
            cell.title.text = mainTodo.title
            cell.title.delegate = self
            cell.memo.text = mainTodo.memo
            cell.memo.delegate = self
            
            if mainTodo.numberOfSubTodo > 0 {
                cell.btn.image = mainTodo.isOpen! ? UIImage(named: "disclosure_open") : UIImage(named: "disclosure_close")
                cell.btn.isUserInteractionEnabled = true
                cell.btn.tag = indexPath.section
                cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
                
                cell.childNumber.text = mainTodo.isOpen! ? "" : String(todoList[indexPath.section].numberOfSubTodo)
                
                cell.shrinkAccessory(false) // constraint 설정, not shrink
            } else { // shrink
                cell.shrinkAccessory(true)
            }
        
            cell.indentLeading(false) // indent 설정
        
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            cell.selectImg.image = subTodo.isFinish! ? UIImage(named: "click") : UIImage(named: "unclick")
            cell.selectImg.isUserInteractionEnabled = true
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
        
        if indexPath.row == 0 { // main cell
            let mainTodo = todoList[indexPath.section]
            cell.selectImg.image = mainTodo.isFinish! ? UIImage(named: "click") : UIImage(named: "unclick")
            cell.selectImg.isUserInteractionEnabled = true
            cell.title.text = mainTodo.title
            cell.title.delegate = self
            
            if mainTodo.numberOfSubTodo > 0 {
                cell.btn.image = mainTodo.isOpen! ? UIImage(named: "disclosure_open") : UIImage(named: "disclosure_close")
                cell.btn.isUserInteractionEnabled = true
                cell.btn.tag = indexPath.section
                cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
                cell.childNumber.text = mainTodo.isOpen! ? "" : String(todoList[indexPath.section].numberOfSubTodo)
                cell.shrinkAccessory(false) // constraint 설정, not shrink
            } else { // shrink
                cell.shrinkAccessory(true)
            }
        
            cell.indentLeading(false) // indent 설정
        
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            cell.selectImg.image = subTodo.isFinish! ? UIImage(named: "click") : UIImage(named: "unclick")
            cell.selectImg.isUserInteractionEnabled = true
            cell.title.text = subTodo.title
            cell.title.delegate = self
            
            cell.shrinkAccessory(true)
            cell.indentLeading(true) // indent 설정
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if hasMemo(indexPath: indexPath) {
            cell = setupMemoCell(indexPath: indexPath)
        } else {
            cell = setupBasicCell(indexPath: indexPath)
        }
//
//        let dragInteraction = UIDragInteraction (delegate : self)
//        dragInteraction.isEnabled = true
//        cell.addInteraction(dragInteraction)

        
//         cell.selectionStyle = indexPath.row != 0 ? .gray : .none
        
        
        return cell
    }
}

//extension TodoListViewController: UIDragInteractionDelegate {
//    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
//        return [UIDragItem(itemProvider: NSItemProvider())]
//    }
//
//    func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
//        let pos = session.location(in: tableView)
//        print("pos] \(pos)")
//    }
//}

extension TodoListViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print("itemsForBeginning] \(indexPath)")
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
    
    
    
//    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
//
//        print("dragging] section =\(indexPath.section), row = \(indexPath.row)")
//
//        let previewParameters = UIDragPreviewParameters()
//        previewParameters.visiblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 50, height: 50), cornerRadius: 5)
//        return previewParameters
//    }
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
    
    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {

        print("dropPreview] \(indexPath)")
        let previewParameters = UIDragPreviewParameters()
//        previewParameters.visiblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 50, height: 50), cornerRadius: 5)
        previewParameters.backgroundColor = .purple
        return previewParameters
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
//            let data = todoList.remove(at: sourceIndexPath.section)
            
            guard !isLastDestination(destinationPath: destinationIndexPath) else { // 마지막 셀이 아닐 때
                let data = todoList.remove(at: sourceIndexPath.section) // 마지막 셀일 때
                
                todoList.append(data)
                return
            }
            
            if isP(sourceIndexPath: sourceIndexPath) && (destinationIndexPath.row != 0) { // x섹션의 y위치로 삽입
                guard isC(sourceIndexPath: destinationIndexPath) && todoList[destinationIndexPath.section].isOpen! else {
//                guard isPc(sourceIndexPath: destinationIndexPath) && todoList[destinationIndexPath.section].isOpen! else {
                    let data = todoList.remove(at: sourceIndexPath.section) // x섹션 그 자리에 삽입
                    var toSection = destinationIndexPath.section
                    if sourceIndexPath.section > destinationIndexPath.section { toSection += 1 }
                    todoList.insert(data, at: toSection)
                    return
                }
//                let data = todoList.remove(at: sourceIndexPath.section)
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
//            let data = todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
            
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
            // objID처리는.... 나중에 DAO연결할 때 처리함
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
            // objID는 나중에 DAO할 때 처리하기로
            todoList[destinationIndexPath.section].subTodoList.append(newSubs)
            todoList[destinationIndexPath.section].isOpen = true
            todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
        }
    }
}
