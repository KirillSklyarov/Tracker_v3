//
//  EditingCategoryViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class EditingCategoryViewController: UIViewController {
    
    // MARK: - UI Properties
    let categoryNameTextField = UITextField()
    let doneButton = UIButton()
    
    // MARK: - Private Properties
    let viewModel = EditingCategoryViewModel()
            
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - IB Actions
    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        categoryNameTextField.text = ""
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        guard let newCategoryHeader = categoryNameTextField.text else { return }
        viewModel.doneButtonTapped(newCategoryHeader: newCategoryHeader)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func setupTextField() {
        
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
        
        let clearTextStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.addArrangedSubview(clearTextFieldButton)
            stack.addArrangedSubview(rightPaddingView)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.widthAnchor.constraint(equalToConstant: 28).isActive = true
            return stack
        } ()
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        categoryNameTextField.leftView = leftPaddingView
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.rightView = clearTextStack
        categoryNameTextField.rightViewMode = .whileEditing
        categoryNameTextField.textAlignment = .left
        categoryNameTextField.layer.cornerRadius = 10
        categoryNameTextField.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        categoryNameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        categoryNameTextField.delegate = self
    }
    
    private func setupUI() {
        
        setupDoneButton()
        
        setupTextField()
        
        self.title = "Editing a category".localized()
        
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
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 15
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.backgroundColor = .black
    }
}
