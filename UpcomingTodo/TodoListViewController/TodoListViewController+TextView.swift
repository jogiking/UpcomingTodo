//
//  TodoListViewController+TextView.swift
//  Todo
//
//  Created by turu on 2021/03/18.
//

import UIKit

extension TodoListViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("textViewShoulBeginEditing] \(textView.text)")
        if let cell = textView.superview?.superview as? UITableViewCell {
            if editingStatus.isEditingMode == false {
                editingStatus = (true, cell as? UITableViewCell, textView, tableView.indexPath(for: cell as! UITableViewCell))
            }
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 해당하는 셀의 btn 이미지를 바꿔야한다(생기는거로)
        print("textViewDidBeginEditing")
        
        self.textViewHeight = textView.frame.height
        
        if let cell = textView.superview?.superview as? DynamicCellProtocol {
            cell.shrinkAccessory(false)
            cell.changeBtnStatusImage(statusType: .InfoCircle)

//            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                (cell as! UITableViewCell).layoutIfNeeded()
                self.tableView.endUpdates()
//            }
            
            editingStatus = (true, cell as? UITableViewCell, textView, tableView.indexPath(for: cell as! UITableViewCell))
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        print("textViewShouldEndEditing] dd")
//        return true
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEtiting] \(textView.text)")
       
        
//        let cell = textView.superview?.superview as! UITableViewCell
        textEditingFinish(editingStatus.indexPath!, textView) // 여기서 shrink도 함
        
//        if editingStatus.isEditingMode {
//            editingStatus = (false, nil, nil, nil)
//        }
        if editingStatus.textView == textView {
            editingStatus = (false, nil, nil, nil)
        }
        
        
//
//        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.layoutIfNeeded()
            self.tableView.endUpdates()
//        }
//        textView.resignFirstResponder()
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let beforeHeight = self.textViewHeight
//        textView.sizeToFit()
    
        print("textViewDidChange] before = \(beforeHeight), textViewSize=\(textView.frame)")

//        let offset = tableView.contentOffset.y - (editingStatus.cell?.frame.origin.y)!
//        print("offset=\(tableView.contentOffset.y)")
        let diff = textView.frame.height - beforeHeight
        if diff > 0 {
            print("diff=\(diff)")
//            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + diff), animated: false)
                        tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + diff), animated: false)
            self.textViewHeight = textView.frame.height
        }
        
    
//        for cell in tableView.visibleCells {
//            UIView.animate(withDuration: 0.3) {
//                cell.frame = cell.frame.offsetBy(dx: 0, dy: offset)
//
//            }
//        }
//        tableView.contentOffset.y -= 15
//        tableView.setContentOffset(CGPoint(x: 0, y: 15), animated: false)
        
        
        self.tableView.beginUpdates()
        self.tableView.layoutIfNeeded()
        self.tableView.endUpdates()
        
        
//        tableView.scrollToRow(at: editingStatus.indexPath!, at: .top, animated: true)
        
    }
    
    
}
