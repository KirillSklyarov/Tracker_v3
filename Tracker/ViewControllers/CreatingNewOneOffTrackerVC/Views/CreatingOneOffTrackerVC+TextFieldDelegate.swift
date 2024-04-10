//
//  CreatingOneOffTrackerVC+TextFieldDelegate.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import UIKit

// MARK: - TextFieldDelegate - control of TextField length
extension CreatingOneOffTrackerVC: UITextFieldDelegate {
    
    func setupTextField() {
        
        let rightPaddingView = UIView()
        let clearTextFieldButton: UIButton = {
            let button = UIButton(type: .custom)
            let configuration = UIImage.SymbolConfiguration(pointSize: 17)
            let imageColor = UIColor(named: "createButtonGrayColor") ?? .lightGray
            let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(imageColor)
            button.setImage(image, for: .normal)
            button.addTarget(self, action: #selector(clearTextButtonTapped), for: .touchUpInside)
            return button
        } ()
        
        lazy var clearTextStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.addArrangedSubview(clearTextFieldButton)
            stack.addArrangedSubview(rightPaddingView)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.widthAnchor.constraint(equalToConstant: 28).isActive = true
            return stack
        } ()
        
        trackerNameTextField.rightView = clearTextStack
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount <= 38 {
            hideLabelExceedTextFieldLimit()
//            isCreateButtonEnable()
            textField.textColor = .black
            return true
        } else {
            print("Check: opps")
            showLabelExceedTextFieldLimit()
            textField.textColor = .red
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNameTextField.resignFirstResponder()
    }
}
