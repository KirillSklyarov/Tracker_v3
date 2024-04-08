//
//  CreatingNewCategoryVC+TextFieldDelegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import UIKit

// MARK: - UITextFieldDelegate
extension CreatingNewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        categoryNameTextField.resignFirstResponder()
    }
}
