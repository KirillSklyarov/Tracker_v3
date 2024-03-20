//
//  UIViewController+Ext.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 20.03.2024.
//

import UIKit


extension UIViewController {
    
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
}
