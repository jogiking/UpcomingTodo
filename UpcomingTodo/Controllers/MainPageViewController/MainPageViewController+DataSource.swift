//
//  MainPageViewController+DataSource.swift
//  Todo
//
//  Created by turu on 2021/03/18.
//

import UIKit

extension MainPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        navItem.rightBarButtonItem?.title = "Done".localized
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        navItem.rightBarButtonItem?.title = "Edit".localized
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let data = appDelegate.myData.remove(at: sourceIndexPath.row)
        appDelegate.myData.insert(data, at: destinationIndexPath.row)
        
        self.dao.updateDisplayOrder() // 순서 동기화
    }
       
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("in delete")
        if editingStyle == .delete {
            
            let catalog = appDelegate.myData[indexPath.row]
            if dao.delete(catalog.objectID!) {
                appDelegate.myData.remove(at: indexPath.row)
                dao.updateDisplayOrder(removeCatalogIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                updateMainPage()
                
                if appDelegate.myData.count < 1 {
                    DispatchQueue.main.async {
                        tableView.isEditing = false
                        for i in 0...self.mainStackView.arrangedSubviews.count - 3 {
                            let item = self.mainStackView.arrangedSubviews[i]
                            item.isHidden = false
                            item.alpha = 1
                        }
                        self.navItem.rightBarButtonItem?.title = "Edit".localized
                    }
                    
                }
                self.updatePickerView()
                self.editModePickerView.reloadAllComponents()
            }            
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("accessory touched in \(indexPath.row)")
        
        let alertController = UIAlertController(title: "Edit List Name".localized, message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { (save) in
            print("확인 눌림")
            // 현재 들어있는 텍스트가 카탈로그 이름으로 저장된다.
            guard let text = alertController.textFields?.first?.text else { return }
            guard text != self.appDelegate.myData[indexPath.row].name else { return }
            
            // coredata 갱신
            if self.dao.editCatalogName(self.appDelegate.myData[indexPath.row].objectID!, name: text) {
                // 갱신 성공시 로컬 배열에 저장함
                self.appDelegate.myData[indexPath.row].name = text
                self.updateMainPage()
                print("이름 변경 성공!")
            }
            
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive) { (_) in
            print("취소 눌림")
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
        }
        
        alertController.addTextField { (tf) in
            tf.borderStyle = .none
            tf.text = self.appDelegate.myData[indexPath.row].name
            tf.placeholder = self.appDelegate.myData[indexPath.row].name
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: tf, queue: .main) { (_) in
                let textCount = tf.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                
                okAction.isEnabled = textIsNotEmpty
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("MainPageVC+didSelectRowAt] indexPath=\(indexPath.row)")
        guard let todoListVC = self.storyboard?.instantiateViewController(identifier: "todoListVC") as? TodoListViewController else {
            return
        }
        
        todoListVC.indexOfCatalog = indexPath.row
        
//        
//        self.navigationItem.title = "Back".localized
        self.navigationController?.pushViewController(todoListVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell",for: indexPath)
        cell.textLabel?.text = appDelegate.myData[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        let detailNumber = "\(appDelegate.myData[indexPath.row].todoList.count)"
        cell.detailTextLabel?.text = detailNumber
        cell.tintColor = UIColor.appColor(.systemButtonTintColor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("numberOfRowInSection : \(appDelegate.myData.count)")
        return appDelegate.myData.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension UITableView {
    open override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
