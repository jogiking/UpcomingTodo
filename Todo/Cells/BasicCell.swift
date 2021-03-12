//
//  BasicCell.swift
//  Todo
//
//  Created by turu on 2021/02/28.
//

import UIKit

enum TableViewCellRightButtonStatus: String {
    case DisclosureOpen =  "disclosure_open"
    case DisclosureClose = "disclosure_close"
    case InfoCircle = "info.circle"
}

protocol DynamicCellProtocol {
    var rightBtnUITapGestureRecognizerDelegate: UITapGestureRecognizer? { get set }
    
    func shrinkAccessory(_: Bool)
    func indentLeading(_: Bool)
    func changeBtnStatusImage(statusType: TableViewCellRightButtonStatus)
    func changeSelectImg(isFinish: Bool)
}

class BasicCell: UITableViewCell, DynamicCellProtocol {
    var rightBtnUITapGestureRecognizerDelegate: UITapGestureRecognizer?    

    @IBOutlet weak var selectImg: UIImageView!
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var childNumber: UILabel!
    @IBOutlet weak var btn: UIImageView!
    
    @IBOutlet weak var selectImgLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var childNumberWidthConstraint: NSLayoutConstraint!
    
    let constantOfBtnWidth: CGFloat = 40
    let constantOfChildNumberWidth: CGFloat = 31.5
    let constantOfSelectImgLeading: CGFloat = 20
    let constantOfIndent: CGFloat = 50
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

    func shrinkAccessory(_ flag: Bool) {
        if flag {
            btnWidthConstraint.constant = 0
            childNumberWidthConstraint.constant = 0
        } else {
            btnWidthConstraint.constant = constantOfBtnWidth
            childNumberWidthConstraint.constant = constantOfChildNumberWidth
            
        }
    }
    
    func indentLeading(_ flag: Bool) {
        if flag {
            selectImgLeadingConstraint.constant = constantOfIndent
        } else {
            selectImgLeadingConstraint.constant = constantOfSelectImgLeading
        }
    }
    
    func changeBtnStatusImage(statusType: TableViewCellRightButtonStatus) {
        switch statusType {
        case .InfoCircle :
            btn.image = UIImage(systemName: statusType.rawValue)
            childNumberWidthConstraint.constant = 0
            
        case .DisclosureClose, .DisclosureOpen :
            btn.image = UIImage(named: statusType.rawValue)
            shrinkAccessory(false)
        }
        
    }
    
    func changeSelectImg(isFinish: Bool) {
        self.selectImg.image = isFinish ? UIImage(named: "click") : UIImage(named: "unclick")
    }
}
