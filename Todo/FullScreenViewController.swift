//
//  FullScreenViewController.swift
//  Todo
//
//  Created by turu on 2021/03/12.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    @IBOutlet weak var upcomingView: UpcomingView!
    @IBOutlet weak var yearMonthDayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var targetData: TodoData?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        upcomingView.targetData = self.targetData
        upcomingView.onTimerStart {
            let date = Date()
            
            let yearMonthDayLabelFormatter = DateFormatter()
            yearMonthDayLabelFormatter.dateFormat = "yyyy년 MM월 dd일"
            
            let timeLabelFormatter = DateFormatter()
            timeLabelFormatter.dateFormat = "a hh시 mm분 ss초"
            
            self.yearMonthDayLabel.text = yearMonthDayLabelFormatter.string(from: date)
            self.timeLabel.text = timeLabelFormatter.string(from: date)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        self.upcomingView.onTimerStop()
    }
    
    
    @IBAction func onSwipe(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
}
