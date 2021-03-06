//
//  AddCatalogViewController.swift
//  Todo
//
//  Created by turu on 2021/02/24.
//

import UIKit

class AddCatalogViewController: UIViewController {

    lazy var dao = TodoDAO()
    
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.inputTextField.becomeFirstResponder()
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard inputTextField.hasText == true else {
            let alertController = UIAlertController(title: "내용을 입력하세요", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let data = CatalogData()
        data.name = inputTextField.text
        data.regDate = Date()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        data.displayOrder = appDelegate.myData.count
        self.dao.insert(data)
    
        guard let pvc = self.presentingViewController as? UINavigationController else { return }
        
        guard let firstVC = pvc.topViewController as? MainPageViewController else {
            return
        }
        
        self.dismiss(animated: true, completion: {
            print("completion")
            firstVC.updateMainPage()
        })
    }
    
}

extension AddCatalogViewController: UITextFieldDelegate {
    
}
