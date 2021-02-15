//
//  ViewController.swift
//  Todo
//
//  Created by turu on 2021/02/15.
//
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTextView: UITextView!
    
    var todoList: [TodoData] = []
    
    var beforeTouch: IndexPath?
    
    func createData(size: Int) {
        for i in 1...size {
            let data =  TodoData.init(index: i)
            
            var j = 1
            while j < i {
                let dt = Todo()
                //                ifdt.memo = ""
                data.subTodoList.append(dt)
                j += 1
            }
            if i % 2 == 1 {
                data.isOpen = true
            }
            todoList.append(data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // 데이터가 없는 곳에도 줄 간격이 생기는 것을 방지
        //        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        let nibName = UINib(nibName: "NormalCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "normal_cell")
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        addTextView.delegate = self
        addTextView.text = ""
        
        createData(size: 5) // MUST OVER 1
    }
    
}

extension ViewController: UITextViewDelegate {
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

extension ViewController: UITableViewDelegate, UITableViewDataSource,
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
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
    
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
        //        print("heightForFooterInSection:section:\(section)//")
        return 1
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("accessory was tapped!")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            cell.memo.text = todoList[indexPath.section].memo
            cell.selectImgLeadingConstraint.constant = 20
            
            if todoList[indexPath.section].numberOfSubTodo > 0 { // sub Todo가 있을 때
                cell.btn.isUserInteractionEnabled = true
                cell.btn.tag = indexPath.section
                cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
                cell.btnWidthConstraint.constant = 40
                if todoList[indexPath.section].isOpen == true {
                    cell.btn.image = UIImage(named: "disclosure_open")
                    cell.childNumber.text = ""
                    cell.childNumberWidthConstraint.constant = 0
                    
                } else {
                    cell.childNumber.text = String(todoList[indexPath.section].numberOfSubTodo)
                    cell.childNumber.sizeToFit()    // 제대로 되는지?? 제대로 안되면 31정도 값을 넣어줘야함.......
                    
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
            cell.memo.text = subs.memo
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
