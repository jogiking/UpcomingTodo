//
//  CardBoardView.swift
//  Todo
//
//  Created by turu on 2021/02/22.
//

import UIKit

@IBDesignable
class CardBoardView: UIView {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var countTitle: UILabel!
    
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
        let view = bundle.loadNibNamed("CardBoardView", owner: self, options: nil)?.first as! UIView
        
        view.frame = bounds
        view.subviews.first!.backgroundColor = .lightGray
        
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        
        self.addSubview(view)
    }
}
