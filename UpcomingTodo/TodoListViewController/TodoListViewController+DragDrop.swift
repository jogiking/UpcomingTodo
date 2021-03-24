//
//  TodoListViewController+Drag.swift
//  Todo
//
//  Created by turu on 2021/03/18.
//

import UIKit

extension TodoListViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print("itemsForBeginning] \(indexPath)")
        if editingStatus.isEditingMode && (editingStatus.textView?.text.isEmpty)! {
            editingStatus.textView?.text = "New Todo".localized
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
        self.completeButton.isEnabled = false
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
