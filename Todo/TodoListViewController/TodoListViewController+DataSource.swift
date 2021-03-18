//
//  TodoListViewController+DataSource.swift
//  Todo
//
//  Created by turu on 2021/03/18.
//

import UIKit

extension TodoListViewController: UITableViewDelegate,
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분"
        guard let date = todoList[section].deadline else { return nil }
        let dateString = dateFomatter.string(from: date)
        return "\(dateString)까지"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = tableView.backgroundColor
        header.textLabel?.textColor = .systemBlue
    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return section == todoList.count - 1 ? 0 : 1
//    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        print("delete?? section: \(indexPath.section), row : \(indexPath.row)")
        if editingStyle == .delete {
            // commit위치가 빈셀의 바로 위일때만 빈셀의 지워짐도 같이처리됨
            if indexPath.row == 0 {
                todoList.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                todoList[indexPath.section].subTodoList.remove(at: indexPath.row - 1)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                //현재 indexPath가 isEdidtingMode인 셀이 아니라면 업데이트
                if editingStatus.isEditingMode {
                    let isEditingParentCell = tableView.indexPath(for: editingStatus.cell!) != IndexPath(row: 0, section: indexPath.section)
                    editingStatus.textView?.resignFirstResponder()
                    if isEditingParentCell {
                        tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .automatic)
                    }
                } else {
                    tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .automatic)
                }
            }
        }
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
    
    func setupMemoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! MemoCell
        cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
        cell.btn.isUserInteractionEnabled = true
        cell.selectImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSelectImage(_:))))
        cell.selectImg.isUserInteractionEnabled = true
        
        if indexPath.row == 0 { // main cell
            let mainTodo = todoList[indexPath.section]
            cell.changeSelectImg(isFinish: mainTodo.isFinish!)
            cell.title.text = mainTodo.title
            cell.title.delegate = self
            cell.memo.text = mainTodo.memo
            
            if mainTodo.numberOfSubTodo > 0 {
                cell.btn.image = mainTodo.isOpen! ? UIImage(named: "disclosure_open") : UIImage(named: "disclosure_close")
                cell.btn.tag = indexPath.section

                cell.childNumber.text = mainTodo.isOpen! ? "" : String(todoList[indexPath.section].numberOfSubTodo)
                
                cell.shrinkAccessory(false) // constraint 설정, not shrink
            } else { // shrink
                cell.shrinkAccessory(true)
            }
        
            cell.indentLeading(false) // indent 설정
        
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            cell.changeSelectImg(isFinish: subTodo.isFinish!)
            cell.title.text = subTodo.title
            cell.title.delegate = self
            cell.memo.text = subTodo.memo
            
            cell.shrinkAccessory(true)
            cell.indentLeading(true) // indent 설정
        }
        
        return cell
    }
    
    func setupBasicCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! BasicCell
        cell.btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOpenImage(_:))))
        cell.btn.isUserInteractionEnabled = true
        cell.selectImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSelectImage(_:))))
        cell.selectImg.isUserInteractionEnabled = true
        if indexPath.row == 0 { // main cell
            let mainTodo = todoList[indexPath.section]
            cell.changeSelectImg(isFinish: mainTodo.isFinish!)
            cell.title.text = mainTodo.title
            cell.title.delegate = self
            
            if mainTodo.numberOfSubTodo > 0 {
                cell.btn.image = mainTodo.isOpen! ? UIImage(named: "disclosure_open") : UIImage(named: "disclosure_close")
                cell.btn.tag = indexPath.section

                cell.childNumber.text = mainTodo.isOpen! ? "" : String(todoList[indexPath.section].numberOfSubTodo)
                cell.shrinkAccessory(false) // constraint 설정, not shrink
            } else { // shrink
                cell.shrinkAccessory(true)
            }
        
            cell.indentLeading(false) // indent 설정
        
        } else { // sub cell
            let subTodo = todoList[indexPath.section].subTodoList[indexPath.row - 1]
            cell.changeSelectImg(isFinish: subTodo.isFinish!)
            cell.title.text = subTodo.title
            cell.title.delegate = self
            
            cell.shrinkAccessory(true)
            cell.indentLeading(true) // indent 설정
        }
        
        return cell
    }
}
