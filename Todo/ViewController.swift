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
    var startIndexPath: IndexPath?
    
    func createData(size: Int) {
        for i in 1...size{
            let data =  TodoData.init(index: i)
            data.title = "\(i)번째 todo"
            var j = 1
            while j < i {
                let dt = Todo()
                dt.title = "\(i)번째 todo의 \(j)번째 subs"
                if j % 2 == 0 {
                    dt.memo = nil
                }
                data.subTodoList.append(dt)
                j += 1

                if i % 2 == 1 {
                    data.isOpen = true
                }
            }
            todoList.append(data)
        }
            
        let data = TodoData.init(index: 10)
        data.title = "시험용 todo"
        let dt = Todo()
        dt.title = "시험용 todo의 1번째 subs"
        data.subTodoList.append(dt)
        todoList.insert(data, at: 0)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // 데이터가 없는 곳에도 줄 간격이 생기는 것을 방지
        tableView.estimatedRowHeight = 60
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
        print("itemsForBeginning] \(indexPath)")
        self.startIndexPath = indexPath
        
        let section = indexPath.section
        if (indexPath.row == 0) && todoList[section].isOpen! {
            todoList[section].isOpen = false
            tableView.reloadSections(IndexSet(section...section), with: .none)
        }
        
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        print("targetIndexPathForMoveFromRowAt] source=\(sourceIndexPath), proposed=\(proposedDestinationIndexPath)")
//
////        if
//        // 만약 섹션간 전환이 필요한 경우라면 셀이 직접 이동하는걸 막고, = proposedIndexPath를 소스와 동일하게?
//        // 데이터 소스를 변경만, moveSection메서드를 이용해보기
//
//
//        return proposedDestinationIndexPath
//    }
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
// 여기에 들어오는 source와 destination의 indexPath에 맞춰서 데이터 소스만 변경해줘야함
//        // 내가 여기서 데이터 소스를 변경하는게 그대로 반영되는것이 아니고
//        // 이 메서드를 호출한 시점에 이미 어떻게 변경되어야하는게 정해진듯?
//        // 그렇다면 이 메서드의 마지막에 moveSection을 두면 어떻게 되는걸까? 아까 비슷하게 했는데 안되었음
//        // 아마도 source랑 destination이랑 안맞아서 그런건가
//        print("moveRowAt")
//        if sourceIndexPath.row == 0 {
//            let data = todoList[sourceIndexPath.section]
//            var row = todoList[destinationIndexPath.section].isOpen! ? todoList[destinationIndexPath.section].numberOfSubTodo : 0
//            row += 1
//
//            todoList.remove(at: sourceIndexPath.section)
//
//
//            if destinationIndexPath.row == row {
//                todoList.insert(data, at: destinationIndexPath.section)
//                tableView.beginUpdates()
//                tableView.moveRow(at: IndexPath(row: 0, section: 1), to: IndexPath(row: 0, section: 0))
//                tableView.endUpdates()
//            } else {
//                todoList[destinationIndexPath.section].subTodoList.insert(data, at: destinationIndexPath.row - 1)
//            }
//
//        } else {
//            let data = todoList[sourceIndexPath.section].subTodoList[sourceIndexPath.row - 1]
//            var row = todoList[destinationIndexPath.section].isOpen! ? todoList[destinationIndexPath.section].numberOfSubTodo : 0
//            row += 1
//            todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
//
//            if destinationIndexPath.row == row {
//                let todoData = TodoData()
//                todoData.title = data.title
//                todoData.memo = data.memo
//                todoData.regDate = data.regDate
//                todoData.isFinish = data.isFinish
//                todoData.objectID = data.objectID
//
//                todoList.insert(todoData, at: destinationIndexPath.section)
//            } else {
//                todoList[destinationIndexPath.section].subTodoList.insert(data, at: destinationIndexPath.row - 1)
//            }
//        }
////        self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
//    }
    
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
        return false
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
    
    func updateDatasource2(destinationIndexPath: IndexPath) {
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
    
    func updateDatasource(destinationIndexPath: IndexPath) {
        let sourceIndexPath = self.startIndexPath!
        if sourceIndexPath.row == 0 { // 출발지는 parent 타입의 셀. p0 pc
            let data = todoList[sourceIndexPath.section]
//            var row = todoList[destinationIndexPath.section].isOpen! ? todoList[destinationIndexPath.section].numberOfSubTodo : 0
//            row += 1
            
            // pc ->
            // 도착지의 셀타입을 판별한다
            // dest가 child일 경우 들어가야하는 위치 todoList[x].subTodoList[y - 1]
            // dest가 p일 경우에는 todoList[x] 근데 이때 필요조건은 y = 0이다.
            
            var row = todoList[destinationIndexPath.section].numberOfSubTodo
            
            todoList.remove(at: sourceIndexPath.section)
            
            if destinationIndexPath.row == row {
                todoList.insert(data, at: destinationIndexPath.section)
            } else {
                todoList[destinationIndexPath.section].subTodoList.insert(data, at: destinationIndexPath.row - 1)
            }
            
        } else { // 출발지는 child 타입의 셀
            let data = todoList[sourceIndexPath.section].subTodoList[sourceIndexPath.row - 1]
            var row = todoList[destinationIndexPath.section].isOpen! ? todoList[destinationIndexPath.section].numberOfSubTodo : 0
            row += 1
            todoList[sourceIndexPath.section].subTodoList.remove(at: sourceIndexPath.row - 1)
            
            if destinationIndexPath.row == row {
                let todoData = TodoData()
                todoData.title = data.title
                todoData.memo = data.memo
                todoData.regDate = data.regDate
                todoData.isFinish = data.isFinish
                todoData.objectID = data.objectID
                
                todoList.insert(todoData, at: destinationIndexPath.section)
            } else {
                todoList[destinationIndexPath.section].subTodoList.insert(data, at: destinationIndexPath.row - 1)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        print("dropSession] section=\(destinationIndexPath?.section), row=\(destinationIndexPath?.row)")

        var dropProposal = UITableViewDropProposal(operation: .cancel)
        
        // Accept only one drag item.
        guard session.items.count == 1 else { return dropProposal }
        
        // The .move drag operation is available only for dragging within this app and while in edit mode.
        if session.localDragSession != nil {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .automatic)
//            if (destinationIndexPath?.row == 0) && // 도착지점이 P, Pc일 때
//                (todoList[startIndexPath!.section].numberOfSubTodo == 0 || // 시작지점에 P이거나
//                    startIndexPath!.row > 0 ) && // C일 때
//                (startIndexPath?.section != destinationIndexPath?.section) { // 그리고 자기 자신 섹션은 아닌 경우
//                dropProposal = UITableViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
//            } else {
//                dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//            }
        } else {
            // Drag is coming from outside the app.
            dropProposal = UITableViewDropProposal(operation: .cancel)
        }

        return dropProposal
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        // 순서변경시에는 호출이 안되고, 삽입시에는 호출이 됨. destinationIndexPath도 알 수 있음
        print("performDropWith] \(coordinator.proposal.intent.rawValue), dest=\(coordinator.destinationIndexPath)")
        
        // 1이 아마 move고 2가 insert 일듯
        switch coordinator.proposal.intent {
        case .insertAtDestinationIndexPath:
            // 여기서 구분하고 movesection 같은거 할지.....]
            updateDatasource2(destinationIndexPath: coordinator.destinationIndexPath!)
            tableView.reloadData()
        ()
        case .insertIntoDestinationIndexPath:
            ()
        default:
            ()
        }
    }
    
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        //print("target:sec:\(sourceIndexPath.section),row:\(sourceIndexPath.row)\\des:sec:\(proposedDestinationIndexPath.section),row:\(proposedDestinationIndexPath.row)")
//        
//        if let cell = tableView.cellForRow(at: proposedDestinationIndexPath) {
//            //            print("from sec:\(sourceIndexPath.section),row:\(sourceIndexPath.row)||to sec: \(proposedDestinationIndexPath.section),row:\(proposedDestinationIndexPath.row)||before sec:\(beforeTouch?.section),row:\(beforeTouch?.row)")
//            if (self.beforeTouch != sourceIndexPath) && (sourceIndexPath != proposedDestinationIndexPath) {
//                if self.beforeTouch == nil {
//                    //                    print("before is nil")
//                    cell.setSelected(true, animated: false)
//                } else {
//                    //                    print("was not nil")
//                    cell.setSelected(true, animated: false)
//                    tableView.cellForRow(at: beforeTouch!)?.setSelected(false, animated: false)
//                }
//                
//            }
//            // cell.setSelected(true, animated: false)
//            self.beforeTouch = proposedDestinationIndexPath
//        }
//        
//        return proposedDestinationIndexPath
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfCell = 1
        let todo = todoList[section]
        
        if todo.isOpen == true {
            numberOfCell += todo.subTodoList.count
        }
//        print("numberOfRowsInSection] section=\(section), rows=\(numberOfCell), title=\(todoList[section].title)")
        return numberOfCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.todoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //        print("heightForFooterInSection:section:\(section)//")
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRowAt] section=\(indexPath.section), row=\(indexPath.row)")
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
                cell.btn.tag = indexPath.section
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
