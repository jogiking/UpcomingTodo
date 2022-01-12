//
//  ThemeColor.swift
//  UpcomingTodo
//
//  Created by turu on 2021/03/25.
//

import UIKit

enum AssetsColor {
    // tint red color
    case upcomingTintColor
    
    case systemButtonTintColor
}

extension UIColor {
  static func appColor(_ name: AssetsColor) -> UIColor {
    switch name {
    case .upcomingTintColor:
        return #colorLiteral(red: 0.9962729812, green: 0.4303903878, blue: 0.4928550124, alpha: 1)
    
    case .systemButtonTintColor:
        return #colorLiteral(red: 0.7905374169, green: 0.003859783057, blue: 0.2996210456, alpha: 1)
    }
  }
}
