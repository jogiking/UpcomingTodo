//
//  TodoDetailViewController.swift
//  Todo
//
//  Created by turu on 2021/03/09.
//

import UIKit

class TodoDetailViewController: UIViewController {
    var isParent = false
    var indexPath: IndexPath!
    
    var todoList: [TodoData]!
    var originalTodo: Todo!
    var hasTimer = false
    let todoTextContents = ["제목", "메모"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("todoDetail.viewDidLoad")
        guard let todoListVC = getPresentingVC() else { return }
        self.todoList = todoListVC.todoList
        let targetTodo = isParent ? todoList[indexPath.section] : todoList[indexPath.section].subTodoList[indexPath.row - 1]
        
        // copy
        originalTodo = Todo()
        originalTodo.title = targetTodo.title
        originalTodo.memo = targetTodo.memo
        originalTodo.objectID = targetTodo.objectID
        originalTodo.regDate = targetTodo.regDate
        
        tableView.dataSource = self
        
    }
    
    func getPresentingVC() -> TodoListViewController? {
        guard let pvc = self.presentingViewController as? UINavigationController else { return nil }
        guard let todoListVC = pvc.topViewController as? TodoListViewController else { return nil }
        return todoListVC
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("TodoDetailVC] viewWillDisappear")
        guard let todoListVC = getPresentingVC() else { return }
        
        self.dismiss(animated: true, completion: {
            todoListVC.tableView.reloadData()
        })
    }
    
    func dismissAndReloadPreviousVC() {
        guard let todoListVC = getPresentingVC() else { return }
        
        self.dismiss(animated: true, completion: {
            todoListVC.tableView.reloadSections(IndexSet(integer: self.indexPath.section), with: .automatic)
        })
    }
    
    func bringContents() -> (title: String?, memo: String?)? {
        // 지금은 title, memo만 작동하게 함
        
        guard let titleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextViewCell else {
            return nil
        }
        guard let memoCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TextViewCell else {
            return nil
        }
        
        let newTitle = titleCell.textView.text
        let newMemo = { () -> String? in
            if memoCell.textView.textColor == UIColor.gray { return nil }
            return memoCell.textView.text
        }()
        
        return (newTitle, newMemo)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        print("saveAction Click.")
        // 만약에 title에 텍스트가 없으면 버튼이안눌려야함
        // 그 외의 경우에는 모두 저장
        guard let contents = bringContents() else { return }
        guard (contents.title != originalTodo.title) || (contents.memo != originalTodo.memo) else {
            dismissAndReloadPreviousVC()
            return
        }
        
        // 콘텐츠 변경작업 수행
        let targetTodo = isParent ? todoList[indexPath.section] : todoList[indexPath.section].subTodoList[indexPath.row - 1]
        targetTodo.title = contents.title
        targetTodo.memo = contents.memo
        
        dismissAndReloadPreviousVC()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        print("cancelAction Click")
        // 변경 사항이 있다면, 종료가 바로 되면 안된다. 액션 시트로 한번 더 띄운다.
        // 변경 사항이 없으면 그대로 종료
        // 변경 사항의 확인은........전용 메서드를 호출해서 처리하는 것으로 한다.

        dismissAndReloadPreviousVC()
    }

}

extension TodoDetailViewController: UITextViewDelegate{
    func placeHolderSetting(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = todoTextContents[textView.tag]
            textView.textColor = .gray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeHolderSetting(textView)
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
        
        if textView.tag == 0 {
            if textView.text.isEmpty {
                saveButton.isEnabled = false
            } else {
                if saveButton.isEnabled == false {
                    saveButton.isEnabled = true
                }
            }
        }
    }
}

extension TodoDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isParent ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return todoTextContents.count
        case 1:
            return hasTimer ? 4 : 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell") as! TextViewCell
            cell.textView.delegate = self
            cell.textView.tag = indexPath.row
            cell.textView.text = indexPath.row == 0 ? originalTodo.title : originalTodo.memo
            placeHolderSetting(cell.textView)
            return cell
            
        case 1:
            switch indexPath.row {
            case 0:
            // 항상 스위치 셀
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchCell
                cell.textLabel?.text = "마감 카운트 다운 설정"
                cell.openSwitch.isOn = hasTimer // 여기서 자동으로 보여지는게달라지는지 체크
                return cell
            case 1:
                // 있다면 statusCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")!
                cell.textLabel?.text = "Start"
                cell.detailTextLabel?.text = "Ends"
                return cell
            case 2:
                // 있다면 datePickerCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell") as! DatePickerCell
                return cell
            case 3:
                // 있다면 statusCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")!
                cell.textLabel?.text = "Start"
                cell.detailTextLabel?.text = "Ends"
                return cell
            default:
                return UITableViewCell()
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    
}

