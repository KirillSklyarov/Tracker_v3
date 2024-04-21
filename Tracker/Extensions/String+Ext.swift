//
//  String+Ext.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 19.04.2024.
//

import Foundation

extension String {

    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}
