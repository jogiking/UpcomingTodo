//
//  TodoListTableFooterView.swift
//  Todo
//
//  Created by turu on 2021/02/26.
//

import UIKit

@IBDesignable
class TodoListTableFooterView: UIView {
    
    @IBOutlet weak var selectImg: UIImageView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var moreBtn: UIButton!
    
    required init?(coder: NSCoder) {
        print("init from IB")
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        print("init from code")
        super.init(frame: frame)
        setup()
    }

    func setup() {
//        let bundle = Bundle(for: type(of: self))
        let view = Bundle.main.loadNibNamed("TodoListTableFooterView", owner: self, options: nil)?.first as! UIView

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }

}
