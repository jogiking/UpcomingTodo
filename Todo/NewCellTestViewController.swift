//
//  NewCellTestViewController.swift
//  Todo
//
//  Created by turu on 2021/02/28.
//

import UIKit


class NewCellTestViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!

    var todoList: [TodoData] = []
    var beforeTouch: IndexPath?
    
    func createData(size: Int) {
        for i in 1...size {
            let data =  TodoData.init(index: i)
            
            var j = 1
            while j < i {
                let dt = Todo()
                if j % 2 == 0 {
                    dt.memo = "test subcell memo"
                }
                data.subTodoList.append(dt)
                j += 1
            }
            if i % 2 == 1 {
                data.isOpen = true
                data.memo = "test maincell memo"
            }
            todoList.append(data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableview.dataSource = self
        tableview.delegate = self
        tableview.dragInteractionEnabled = true
        tableview.dragDelegate = self
        tableview.dropDelegate = self
        
        tableview.estimatedRowHeight = 50
        tableview.rowHeight = UITableView.automaticDimension
        
        tableview.register(UINib(nibName: "BasicCell", bundle: nil), forCellReuseIdentifier: "basicCell")
        tableview.register(UINib(nibName: "MemoCell", bundle: nil), forCellReuseIdentifier: "memoCell")
        
        createData(size: 10)
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
            tableview.reloadSections(IndexSet(section...section), with: .none)
        }
    }
}

extension NewCellTestViewController: UITableViewDelegate,
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
        let cell = tableview.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! MemoCell
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
        let cell = tableview.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicCell
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
        
       
        
        return cell
    }
}
extension NewCellTestViewController: UITableViewDragDelegate,
                                     UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
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
    
}

extension NewCellTestViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        //        print("tvDidEndEditing")
//        if let contentView = textView.superview {
//            if let cell =  contentView.superview as? NormalCell {
//                if let indexPath = tableView.indexPath(for: cell) {
//                    //print("[indexPath] section: \(indexPath.section), row: \(indexPath.row)")
//                    //                    todoList[indexPath.section].
//                    if textView.tag == 0 {
//                        // title
//                        print("title")
//                    } else {
//                        // memo
//                        print("memo")
//                    }
//                }
//            }
//        }
//    }

    func textViewDidChange(_ textView: UITextView) {
        // print(textView.text)
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        print("estimatedSize = \(estimatedSize)")
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                
                UIView.performWithoutAnimation {
                    tableview.beginUpdates()
                    tableview.endUpdates()
                }
            }
        }
    }
}
