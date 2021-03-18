//
//  TodoListViewController+TextView.swift
//  Todo
//
//  Created by turu on 2021/03/18.
//

import UIKit

extension TodoListViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 해당하는 셀의 btn 이미지를 바꿔야한다(생기는거로)
        print("textViewDidBeginEditing")
        
        if let cell = textView.superview?.superview as? DynamicCellProtocol {
            cell.shrinkAccessory(false)
            cell.changeBtnStatusImage(statusType: .InfoCircle)

            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                (cell as! UITableViewCell).layoutIfNeeded()
                self.tableView.endUpdates()
            }
            
            editingStatus = (true, cell as? UITableViewCell, textView, tableView.indexPath(for: cell as! UITableViewCell))
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEtiting] \(textView.text)")
        textEditingFinish()
        
        let cell = textView.superview?.superview as! UITableViewCell
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            cell.layoutIfNeeded()
            self.tableView.endUpdates()
        }
        
        if editingStatus.isEditingMode {
            editingStatus = (false, nil, nil, nil)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.sizeToFit()
        print("textViewDidChange] textViewSize=\(textView.frame)")
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}
