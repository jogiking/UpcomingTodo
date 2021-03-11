//
//  TestViewController.swift
//  Todo
//
//  Created by turu on 2021/03/11.
//

import UIKit

class TestViewController: UIViewController {

    
    @IBOutlet weak var cv: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let customView = UpcomingView()
        customView.frame = cv.bounds
        cv.addSubview(customView)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
