//
//  CreatingNewTrackerVC+TextField.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - UITextFieldDelegate
extension CreatingNewTrackerViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.textColor = AppColors.textFieldText
        viewModel.trackerName = textField.text
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount <= 25 {
            hideLabelExceedTextFieldLimit()
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
