//
//  MainPageViewController+UIScrollDelegate.swift
//  UpcomingTodo
//
//  Created by turu on 2022/01/09.
//

import UIKit

extension MainPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationController = self.navigationController else { return }
        let threshold = navigationController.navigationBar.frame.height
        print("threshold = \(threshold)")
        let alpha = scrollView.contentOffset.y / threshold
        navigationController.navigationBar.subviews.first?.alpha = alpha
        
        updateNavigationTitle()

        print("didScroll] \(scrollView.contentOffset.y)")
    }
}
