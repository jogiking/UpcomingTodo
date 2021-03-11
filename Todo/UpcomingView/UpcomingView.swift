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
    
    
    @IBOutlet weak var timeCounterProgressView: UIProgressView!
    @IBOutlet weak var numberOfCompletionProgressView: UIProgressView!
    
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
}
