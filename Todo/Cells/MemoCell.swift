//
//  MemoCell.swift
//  Todo
//
//  Created by turu on 2021/02/28.
//

import UIKit

class MemoCell: UITableViewCell, DynamicCellProtocol {
    
    @IBOutlet weak var selectImg: UIImageView!
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var childNumber: UILabel!
    @IBOutlet weak var btn: UIImageView!
    @IBOutlet weak var memo: UITextView!
    
    @IBOutlet weak var selectImgLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var childNumberWidthConstraint: NSLayoutConstraint!
    
    let constantOfBtnWidth: CGFloat = 40
    let constantOfChildNumberWidth: CGFloat = 31.5
    let constantOfSelectImgLeading: CGFloat = 20
    let constantOfIndent: CGFloat = 50
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        print("rawValue=\(statusType.rawValue)")
        btn.image = UIImage(systemName: statusType.rawValue)
    }
}
