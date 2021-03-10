//
//  TodoDetailViewController.swift
//  Todo
//
//  Created by turu on 2021/03/09.
//

import UIKit


protocol TodoDetailViewControllerDelegate: AnyObject {
    func todoDetailViewControllerDidFinish(_ todoDetailViewController: TodoDetailViewController)
    func todoDetailViewControllerDidCancel(_ todoDetailViewController: TodoDetailViewController)
}

class TodoDetailViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    var isParent = false
    var todoIndexPath: IndexPath!
    var todoList: [TodoData]!
    
    weak var delegate: TodoDetailViewControllerDelegate?
    
    var hasTimer = false
    let todoTextContents = ["제목", "메모"]
    var hasChanges: Bool {
        guard let contents = bringContents() else { return false }
        let originalTodo = isParent ? todoList[todoIndexPath.section] : todoList[todoIndexPath.section].subTodoList[todoIndexPath.row - 1]
        return (contents.title != originalTodo.title) || (contents.memo != originalTodo.memo)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("todoDetail.viewDidLoad")
        
        hasTimer = true
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//
//        guard let contents = bringContents() else { return }
//        let hasChanges = (contents.title != originalTodo.title) || (contents.memo != originalTodo.memo)
        isModalInPresentation = hasChanges
        print("viewWillLayoutSubviews]\(isModalInPresentation)")
    }
    
    func confirmCancel() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "변경 사항 취소", style: .destructive, handler: { (action: UIAlertAction) in
            
            // 그대로 취소
//            self.dismiss(animated: true)
            self.delegate?.todoDetailViewControllerDidCancel(self)
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("DidAttemptToDismiss")
        confirmCancel()
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
        if hasChanges {
            delegate?.todoDetailViewControllerDidFinish(self)
        } else {
            delegate?.todoDetailViewControllerDidCancel(self)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        print("cancelAction Click")
        if hasChanges {
            confirmCancel()
        } else {
            delegate?.todoDetailViewControllerDidCancel(self)
        }
    }

    @objc func openDatePicker(_ sender: UISwitch) {
        hasTimer = sender.isOn
        tableView.reloadSections(IndexSet(integer: 1), with: .fade)
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
        viewIfLoaded?.setNeedsLayout()
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

extension TodoDetailViewController: UITableViewDelegate {
    
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
            return hasTimer ? 3 : 1
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
            cell.selectionStyle = .none
            let originalTodo = isParent ? todoList[todoIndexPath.section] : todoList[todoIndexPath.section].subTodoList[todoIndexPath.row - 1]
            cell.textView.text = indexPath.row == 0 ? originalTodo.title : originalTodo.memo
            placeHolderSetting(cell.textView)
            return cell
            
        case 1:
            switch indexPath.row {
            case 0:
            // 항상 스위치 셀
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchCell
                cell.selectionStyle = .none
                cell.textLabel?.text = "마감 카운트 다운 설정"
                cell.openSwitch.isOn = hasTimer // 여기서 자동으로 보여지는게달라지는지 체크
                cell.openSwitch.addTarget(self, action: #selector(openDatePicker(_:)), for: .valueChanged)
                return cell
            case 1:
                // 있다면 datePickerCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell") as! DatePickerCell
                cell.datePicker.datePickerMode = .dateAndTime
                
                cell.selectionStyle = .none
                return cell
            case 2:
                // 있다면 statusCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")!
                cell.selectionStyle = .none
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

