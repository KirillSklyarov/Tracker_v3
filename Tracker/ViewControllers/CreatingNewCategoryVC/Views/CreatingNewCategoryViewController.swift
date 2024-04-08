//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingNewCategoryViewController: UIViewController {
    
    // MARK: - UI Properties
    let categoryNameTextField = UITextField()
    let doneButton = UIButton()
    
    // MARK: - Public Properties
    let viewModel = CreatingNewCategoryViewModel()
        
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
        viewModel.updateTableClosure?(newCategoryName)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func setupTextField() {
        
        categoryNameTextField.placeholder = "Введите название категории"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        categoryNameTextField.leftView = leftPaddingView
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.rightViewMode = .whileEditing
        categoryNameTextField.textAlignment = .left
        categoryNameTextField.layer.cornerRadius = 10
        categoryNameTextField.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        categoryNameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        categoryNameTextField.addTarget(self, action: #selector(textFieldEditing), for: .editingChanged)
        
        categoryNameTextField.delegate = self
    }
    
    private func setupUI() {
        
        setupTextField()
        
        setupDoneButton()
        
        self.title = "Новая категория"
        
        view.backgroundColor = UIColor(named: "projectBackground")
        
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
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor(named: "createButtonGrayColor")
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 15
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.isEnabled = false
    }
    
    private func doneButtonIsActive() {
        doneButton.isEnabled = true
        doneButton.backgroundColor = .black
    }
    
    private func doneButtonIsNotActive() {
        doneButton.isEnabled = false
        doneButton.backgroundColor = .systemGray4
    }
}
