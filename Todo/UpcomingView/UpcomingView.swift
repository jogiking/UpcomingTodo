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
        totalDetailLabel.text = "전체 세부 항목 \(data.numberOfSubTodo)건"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 MM월 dd일 HH시 mm분"
        startLabel.text = dateFormatter.string(from: data.regDate!) + " 시작"
        endLabel.text = dateFormatter.string(from: data.deadline!) + " 종료"
        
        var numberOfCompletedSubtodo = 0
        for subTodo in data.subTodoList {
            if subTodo.isFinish! {
                numberOfCompletedSubtodo += 1
            }
        }
        numberOfCompletionLabel.text = "\(numberOfCompletedSubtodo)건 완료"
        numberOfCompletionProgressView.progress = numberOfCompletedSubtodo == 0 ? 0.001 : Float(numberOfCompletedSubtodo) / Float(data.numberOfSubTodo)
        
        let recent = Date()
        timeCounterLabel.text = getDiffDateString(recent: recent, previous: data.regDate!) + " 지남"
                
        let interval = recent - data.regDate!
        let totalSecond = (data.deadline! - data.regDate!).second
        timeCounterProgressView.progress = Float(interval.second!) / Float(totalSecond!)
        
        if recent <= data.deadline! {
            timerLabel.text = getDiffDateString(recent: data.deadline!, previous: recent)
            timeCounterRightLabel.text = "남음"
        } else {
            timerLabel.text = "시간 만료"
            timeCounterRightLabel.text = ""
            timeCounterProgressView.progress = 1
        }
        
        if let completion = self.callbackCompletion {
            completion()
        }
    }
    
    func getDiffDateString(recent: Date, previous: Date) -> String {
        let interval = recent - previous
        let year = interval.month! / 12 == 0 ? "" : "\(interval.month! / 12)년"
        let month = interval.month! % 12 == 0 ? "" : " \(interval.month! % 12)월"
        let day = interval.day! % 365 == 0 ? "" : " \(interval.day! % 365)일"
        let hour = interval.hour! % 24 == 0 ? "" : " \(interval.hour! % 24)시간"
        let minute = interval.minute! % 60 == 0 ? "" : " \(interval.minute! % 60)분"
        let second = interval.second! % 60 == 0 ? "" : " \(interval.second! % 60)초"
        let counterString = year + month + day + hour + minute + second
        return counterString
    }
}

extension Date {

    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }

}
