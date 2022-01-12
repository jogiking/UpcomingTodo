//
//  UITableView+Extension.swift
//  UpcomingTodo
//
//  Created by turu on 2022/01/12.
//

import UIKit

extension UITableView {

    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}
