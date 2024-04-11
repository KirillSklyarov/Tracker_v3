//
//  EditingTrackerVC+TextFieldDelegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import UIKit

// MARK: - UITextFieldDelegate
extension EditingTrackerViewController: UITextFieldDelegate {
    
    // В этом методе ловится изменение текста в текстфилде
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.trackerName = textField.text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount <= 25 {
            hideLabelExceedTextFieldLimit()
            isCreateButtonEnable()
            textField.textColor = .black
            return true
        } else {
            print("Check: opps")
            showLabelExceedTextFieldLimit()
            textField.textColor = .red
            return true
        }
    }
}
