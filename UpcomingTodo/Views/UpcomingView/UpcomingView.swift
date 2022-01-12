//
//  UpcomingView.swift
//  Todo
//
//  Created by turu on 2021/03/11.
//

import UIKit

@IBDesignable
class UpcomingView: UIView {

    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var timeCounterLabel: UILabel!
    @IBOutlet weak var totalDetailLabel: UILabel!
    @IBOutlet weak var numberOfCompletionLabel: UILabel!
    @IBOutlet weak var timeCounterRightLabel: UILabel!
    
    
    @IBOutlet weak var timeCounterProgressView: UIProgressView!
    @IBOutlet weak var numberOfCompletionProgressView: UIProgressView!
    
    var refreshTimer: Timer?
    var targetData: TodoData?
    var callbackCompletion: (() -> Void)?
    
    var i = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("UpcomingView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        self.addSubview(view)
        
        timerLabel.textColor = UIColor.appColor(.upcomingTintColor)
        timeCounterProgressView.tintColor = UIColor.appColor(.upcomingTintColor)
        numberOfCompletionProgressView.tintColor = UIColor.appColor(.upcomingTintColor)
    }
    
    func onTimerStart(callbackCompletion: (() -> Void)? = nil) {
        self.callbackCompletion = callbackCompletion
        
        if let timer = self.refreshTimer {
            if !timer.isValid {
                self.refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(upcomingViewTimerCallback), userInfo: nil, repeats: true)
                RunLoop.main.add(timer, forMode: .common)
                timer.fire()
                
            }
        } else {
            self.refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(upcomingViewTimerCallback), userInfo: nil, repeats: true)
            RunLoop.main.add(self.refreshTimer!, forMode: .common)
            self.refreshTimer!.fire()
        }
    }
    
    func onTimerStop() {
        if let timer = refreshTimer {
            if(timer.isValid){
                timer.invalidate()
            }
        }
    }
    
    @objc func upcomingViewTimerCallback() {
        print("Callback] \(i), data=\(self.targetData?.title)")
        i += 1
        
        guard let data = self.targetData else { return }
        title.text = data.title
        // All 3 details/
        // 전체 세부항목 3건
        
        totalDetailLabel.text = String(format: NSLocalizedString("%@ %d %@", comment: ""), "All ".localized, data.numberOfSubTodo, " Details".localized)
            
            
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
    
        startLabel.text = String(format: NSLocalizedString("%@ %@", comment: ""), dateFormatter.string(from: data.regDate!), "Start".localized)
        endLabel.text = String(format: NSLocalizedString("%@ %@", comment: ""), dateFormatter.string(from: data.deadline!), "End".localized)
        
        var numberOfCompletedSubtodo = 0
        for subTodo in data.subTodoList {
            if subTodo.isFinish! {
                numberOfCompletedSubtodo += 1
            }
        }
        numberOfCompletionLabel.text = String(format: NSLocalizedString("%d %@", comment: ""), numberOfCompletedSubtodo, "Completed".localized)
        numberOfCompletionProgressView.progress = numberOfCompletedSubtodo == 0 ? 0.001 : Float(numberOfCompletedSubtodo) / Float(data.numberOfSubTodo)
        
        let recent = Date()
        timeCounterLabel.text = String(format: NSLocalizedString("%@ %@", comment: ""), getDiffDateString(recent: recent, previous: data.regDate!), "Passed".localized)
                
        let interval = recent - data.regDate!
        let totalSecond = (data.deadline! - data.regDate!).second
        timeCounterProgressView.progress = Float(interval.second!) / Float(totalSecond!)
        
        if recent <= data.deadline! {
            timerLabel.text = getDiffDateString(recent: data.deadline!, previous: recent)
            timeCounterRightLabel.text = "Left".localized
        } else {
            timerLabel.text = "Expired".localized
            timeCounterRightLabel.text = ""
            timeCounterProgressView.progress = 1
        }
        
        if let completion = self.callbackCompletion {
            completion()
        }
    }
    
    func getDiffDateString(recent: Date, previous: Date) -> String {
        let interval = recent - previous
        
        let calendar = Calendar.current
        let offsetComps = calendar.dateComponents([.year,.month,.day, .hour, .minute, .second], from:previous, to:recent)
        
        let year = offsetComps.year ?? 0
        let month = offsetComps.month ?? 0
        let day = offsetComps.day ?? 0
        let hour = offsetComps.hour ?? 0
        let minute = offsetComps.minute ?? 0
        let second = offsetComps.second ?? 0
               
        let yearString = year == 0 ? "" : String(format: NSLocalizedString("%d%@", comment: ""), year, "Y".localized)
        let monthString = month == 0 ? "" : String(format: NSLocalizedString(" %d%@", comment: ""), month, "M".localized)
        let dayString = day == 0 ? "" : String(format: NSLocalizedString(" %d%@", comment: ""), day, "D".localized)
        
        
        let hourString = hour == 0 ? "" : String(format: NSLocalizedString(" %d%@", comment: ""), hour, "hr".localized)
        let minuteString = minute == 0 ? "" : String(format: NSLocalizedString(" %d%@", comment: ""), minute, "min".localized)
        let secondString = second == 0 ? "" : String(format: NSLocalizedString(" %d%@", comment: ""), second, "sec".localized)
        
        let counterString = yearString + monthString + dayString + hourString + minuteString + secondString
        return counterString
    }
}
