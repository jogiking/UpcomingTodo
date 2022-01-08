//
//  SwitchCell.swift
//  Todo
//
//  Created by turu on 2021/03/09.
//

import UIKit

class SwitchCell: UITableViewCell {

    
    @IBOutlet weak var openSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
