//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingNewCategoryViewController: BaseViewController {
    
    // MARK: - UI Properties
    lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.rightViewMode = .whileEditing
        textField.textAlignment = .left
        textField.layer.cornerRadius = 10
        textField.backgroundColor = AppColors.textFieldBackground
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.addTarget(self, action: #selector(textFieldEditing), for: .editingChanged)
        textField.delegate = self
        return textField
    } ()
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(AppColors.createButtonText, for: .normal)
        button.backgroundColor = AppColors.buttonGray
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    } ()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        addTapGestureToHideKeyboard()
        
    }
    
    // MARK: - IB Actions
    @objc private func textFieldEditing(_ sender: UITextField) {
        if let text = sender.text {
            !text.isEmpty ? doneButtonIsActive() : doneButtonIsNotActive()
        }
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        guard let newCategoryName = categoryNameTextField.text else { return }
        viewModel.updateCategory?(newCategoryName)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = "Новая категория"
        
        view.backgroundColor = AppColors.background
        
        view.addSubViews([categoryNameTextField, doneButton])
        
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func doneButtonIsActive() {
        doneButton.isEnabled = true
        doneButton.backgroundColor = AppColors.buttonBlack
    }
    
    private func doneButtonIsNotActive() {
        doneButton.isEnabled = false
        doneButton.backgroundColor = AppColors.buttonGray
    }
}
