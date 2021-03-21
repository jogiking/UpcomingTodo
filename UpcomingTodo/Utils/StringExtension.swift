//
//  String.swift
//  Todo
//
//  Created by turu on 2021/03/19.
//
import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
