//
//  UIView-Extension.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 12.03.2024.
//

import UIKit


extension UIView {
    func addSubViews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}
