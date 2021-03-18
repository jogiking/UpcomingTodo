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
    var deadline: Date? = nil
    let todoTextContents = ["제목", "메모"]
    var hasChanges: Bool {
        guard let contents = bringContents() else { return false }
        let originalTodo = isParent ? todoList[todoIndexPath.section] : todoList[todoIndexPath.section].subTodoList[todoIndexPath.row - 1]
        let commonFlag = (contents.title != originalTodo.title) || (contents.memo != originalTodo.memo)
        guard isParent else { return commonFlag }
        return commonFlag || (deadline != (originalTodo as! TodoData).deadline)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.deadline = todoList[todoIndexPath.section].deadline
        
        hasTimer = {
            if isParent {
                if deadline != nil {
                    return true
                }
            }
            return false
        }()
        
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
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
        view.endEditing(true)
        
        hasTimer = sender.isOn
        tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        view.setNeedsLayout()
        if isParent {
           if hasTimer == false {
                deadline = nil
           }
        }
//           } else {
//                deadline =
//           }
//        }
    }
    
    @objc func datepickerChanged(_ sender: UIDatePicker) {
        print("datepickerChanged] deadline=\(sender.date)")
        view.setNeedsLayout()
        deadline = sender.date
        let datefomatter = DateFormatter()
        datefomatter.dateStyle = .long
        datefomatter.timeStyle = .medium
        let dateString = datefomatter.string(from: deadline!)
        let statusCell = tableView.cellForRow(at: IndexPath(row: 2, section: 1))
        statusCell?.detailTextLabel?.text = dateString
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
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeHolderSetting(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let cell = textView.superview?.superview as? TextViewCell {
            if textView.contentSize.height <= 44 {
                cell.textViewHeightConstraint.constant = 44
            } else if textView.contentSize.height >= 90 {
                cell.textViewHeightConstraint.constant = 90
                
            } else {
                cell.textViewHeightConstraint.constant = textView.contentSize.height
            }
            
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
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
                cell.datePicker.addTarget(self, action: #selector(datepickerChanged(_:)), for: .valueChanged)
                cell.datePicker.minimumDate = Date()
                
                if let date = deadline {
                    cell.datePicker.date = date
                } else {
                    cell.datePicker.date = Date().dayAfter
                    deadline = cell.datePicker.date
                }
                
                
                cell.selectionStyle = .none
                return cell
            case 2:
                // 있다면 statusCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")!
                cell.selectionStyle = .none
                cell.textLabel?.text = "마감시간"
                let datefomatter = DateFormatter()
                datefomatter.dateStyle = .long
                datefomatter.timeStyle = .medium
                
                cell.detailTextLabel?.text = datefomatter.string(from: deadline ?? Date().dayAfter)
                cell.detailTextLabel?.textColor = .red
                return cell
            default:
                return UITableViewCell()
            }
            
        default:
            return UITableViewCell()
        }
    
    }
    
    
}

extension Date {
   static var tomorrow:  Date { return Date().dayAfter }
   static var today: Date {return Date()}
   var dayAfter: Date {
      return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
   }
}
