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
    
    var dao = TodoDAO()
    //    var addTodoFooterView: UIView!
    
    var editingMode = false
    var todoList: [TodoData] = []
    var mainTitleText = ""
    var catalogObjectID: NSManagedObjectID?
    
    var beforeTouch: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTitle.text = mainTitleText
        setupTableViewAndDataList()
        
        //        addTextView.delegate = self
        //        addTextView.text = ""
        
        completeButton.image = UIImage(systemName: "ellipsis.circle")
        completeButton.title = "완료"
        
    }
    
    @IBAction func completionClick(_ sender: Any) {
       
        if editingMode == true {
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: todoList.count - 1)) as? NormalCell, let tv = cell.title else { return }
            
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
        //        if addTodoFooterView != nil {
        //            if let fv = addTodoFooterView as? TodoListTableFooterView {
        //                if fv.inputTextView.text.isEmpty == false {
        //                    // 저장 작업을 시작
        //                    let todo = TodoData()
        //                    todo.title = fv.inputTextView.text
        //                    todo.isOpen = false
        //                    todo.isFinish = false
        //                    todo.regDate = Date()
        //
        //                    self.todoList.append(todo)
        //                    self.dao.insert(todo, catalogObjectID: self.catalogObjectID!)
        //
        //                    stackView.removeArrangedSubview(addTodoFooterView)
        //                    addTodoFooterView.removeFromSuperview()
        //
        //                    self.tableView.invalidateIntrinsicContentSize()
        //                    self.tableView.reloadData()
        //                }
        //            }
        //
        //        }
        
    }
    
    @IBAction func updateView(_ sender: Any) {
        self.tableView.invalidateIntrinsicContentSize()
        self.tableView.reloadData()
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        tableView.invalidateIntrinsicContentSize()
    //        tableView.reloadData()
    //    }
    
    func setupTableViewAndDataList() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // 데이터가 없는 곳에도 줄 간격이 생기는 것을 방지
        //        tableView.estimatedRowHeight = 80//tableView.contentSize.height
        //        tableView.rowHeight = UITableView.automaticDimension
        
        let nibName = UINib(nibName: "NormalCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "normal_cell")
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        print("[TodoView]tableView.contentSize.height : \(tableView.contentSize.height)")
    }
    
    @IBAction func addTodo(_ sender: Any) {
        // 새로운 셀을 테이블에 추가만 한다.
        // 그리고 save누르면 그 셀이 저장이 되게
        
        self.todoList.append(TodoData())
        tableView.insertSections(IndexSet(integer: todoList.count - 1), with: .bottom)
        completeButton.image = nil
        editingMode = true
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: todoList.count - 1)) as? NormalCell {
            guard let tv = cell.title else { return }
            
            tv.becomeFirstResponder()
        }
        //        tableView.beginUpdates()
        //        tableView.insertSections(IndexSet(1...1), with: .bottom)
        //        tableView.insertRows(at: [indexPath], with: .bottom)
        //        tableView.endUpdates()
        //
        //        addTodoFooterView = TodoListTableFooterView(frame: CGRect.zero)
        //        if let footerView = addTodoFooterView as? TodoListTableFooterView {
        //            footerView.inputTextView.delegate = self
        //            footerView.inputTextView.text = ""
        //            footerView.selectImg.image = UIImage(named: "unclick")
        //            footerView.inputTextView.becomeFirstResponder()
        //        }
        //        stackView.addArrangedSubview(addTodoFooterView)
        //        completeButton.image = nil
        //
    }
    
}

extension TodoListViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //        print("tvDidEndEditing")
        if let contentView = textView.superview {
            if let cell =  contentView.superview as? NormalCell {
                if let indexPath = tableView.indexPath(for: cell) {
                    //print("[indexPath] section: \(indexPath.section), row: \(indexPath.row)")
                    //                    todoList[indexPath.section].
                    if textView.tag == 0 {
                        // title
                        print("title")
                    } else {
                        // memo
                        print("memo")
                    }
                }
            }
        }
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

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource,
                                  UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        //print("target:sec:\(sourceIndexPath.section),row:\(sourceIndexPath.row)\\des:sec:\(proposedDestinationIndexPath.section),row:\(proposedDestinationIndexPath.row)")
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfCell = 1
        
        let todo = todoList[section]
        
        if todo.isOpen == true {
            numberOfCell += todo.subTodoList.count
        }
        
        return numberOfCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.todoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cellForRowAt] section = \(indexPath.section), row = \(indexPath.row)")
        let cellId = "normal_cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? NormalCell ?? NormalCell()
        
        cell.selectionStyle = indexPath.row != 0 ? .gray : .none
        cell.title.delegate = self
        cell.memo.delegate = self
        
        if indexPath.row == 0 { // main Todo 일 때
            cell.selectImg.isUserInteractionEnabled = true
            cell.selectImg.image = todoList[indexPath.section].isFinish == false ? UIImage(named: "unclick") : UIImage(named: "click")
            
            
            cell.selectImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSelectImage(_:))))
            
            cell.title.text = todoList[indexPath.section].title
            
            if let memoText = todoList[indexPath.section].memo {
                cell.memo.text = memoText
                cell.titleBottomPriorityConstraint.priority = .defaultLow
            } else {
                cell.titleBottomPriorityConstraint.priority = .defaultHigh
            }
            
            cell.selectImgLeadingConstraint.constant = 20
            
            if todoList[indexPath.section].numberOfSubTodo > 0 { // sub Todo가 있을 때
                cell.btn.isUserInteractionEnabled = true
                cell.btn.tag = 1000 * tableView.tag + indexPath.section
                cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
                cell.btnWidthConstraint.constant = 40
                if todoList[indexPath.section].isOpen == true {
                    cell.btn.image = UIImage(named: "disclosure_open")
                    cell.childNumber.text = ""
                    cell.childNumberWidthConstraint.constant = 0
                    
                } else {
                    cell.childNumber.text = String(todoList[indexPath.section].numberOfSubTodo)
                    cell.btn.image = UIImage(named: "disclosure_close")
                }
            } else { // sub Todo가 없을 때
                
                cell.childNumber.text = ""
                //cell.btn.image = UIImage(named: "disclosure_close")
                cell.childNumberWidthConstraint.constant = 0
                cell.btnWidthConstraint.constant = 0
            }
            
        } else { // sub Todo 일 때 leading 값을 20에서 60으로
            let subs = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            
            cell.selectImgLeadingConstraint.constant = 60
            cell.selectImg.image = subs.isFinish == true ? UIImage(named: "click") : UIImage(named: "unclick")
            cell.selectImg.isUserInteractionEnabled = true
            cell.selectImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSelectImage(_:))))
            cell.title.text = subs.title
            
            if let memoText = subs.memo {
                cell.memo.text = memoText
                cell.titleBottomPriorityConstraint.priority = .defaultLow
            } else {
                cell.titleBottomPriorityConstraint.priority = .defaultHigh
            }
            
            cell.childNumber.text = ""
            cell.btnWidthConstraint.constant = 0
        }
        
        return cell
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
    
}
