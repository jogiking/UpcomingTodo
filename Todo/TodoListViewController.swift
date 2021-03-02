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
    
    var beforeTouch: IndexPath?
    
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
        cell.selectionStyle = indexPath.row != 0 ? .gray : .none
        
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
        cell.selectionStyle = indexPath.row != 0 ? .gray : .none
        
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
//
        
        return cell
    }
}

extension TodoListViewController: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
        let pos = session.location(in: tableView)
        print("pos] \(pos)")
    }
}

extension TodoListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
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

    }
    
    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {

        let previewParameters = UIDragPreviewParameters()
//        previewParameters.visiblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 50, height: 50), cornerRadius: 5)
        previewParameters.backgroundColor = .purple
        return previewParameters
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
//            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath) // 원본
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
//    // ?? 이거 쓰는게 아닌것 같아
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        print("target:sec:\(sourceIndexPath.section),row:\(sourceIndexPath.row)\\des:sec:\(proposedDestinationIndexPath.section),row:\(proposedDestinationIndexPath.row)")

        if let cell = tableView.cellForRow(at: proposedDestinationIndexPath) {
            //            print("from sec:\(sourceIndexPath.section),row:\(sourceIndexPath.row)||to sec: \(proposedDestinationIndexPath.section),row:\(proposedDestinationIndexPath.row)||before sec:\(beforeTouch?.section),row:\(beforeTouch?.row)")
            if (self.beforeTouch != sourceIndexPath) && (sourceIndexPath != proposedDestinationIndexPath) {
                if self.beforeTouch == nil {
                    //                    print("before is nil")
                    cell.setSelected(true, animated: false)
                } else {
                    //                    print("was not nil")
                    cell.setSelected(true, animated: false)
                    tableView.cellForRow(at: beforeTouch!)?.setSelected(false, animated: false)
                }

            }
            // cell.setSelected(true, animated: false)
            self.beforeTouch = proposedDestinationIndexPath
        }

        return proposedDestinationIndexPath
    }
}
