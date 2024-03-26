//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class EditingCategoryViewController: UIViewController {
    
    private let categoryNameTextField = UITextField()
    private lazy var doneButton = setupButtons(title: "Готово")
    
//    var categories = TrackerViewController().categories
    var updateCategoryNameClosure: ( (String) -> Void )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        addTapGestureToHideKeyboard()
    }
    
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
//        categoryNameTextField.addTarget(self, action: #selector(textFildEditing), for: .editingChanged)
        
        categoryNameTextField.delegate = self
    }
    
    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        categoryNameTextField.text = ""
    }
    
    private func setupUI() {
        
        setupTextField()
        
        self.title = "Редактирование категории"
        
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
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        print("doneButtonTapped")
        guard let newCategoryName = categoryNameTextField.text else { return }
        updateCategoryNameClosure?(newCategoryName)
        dismiss(animated: true)
    }
    
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.backgroundColor = .black
        return button
    }
}

extension EditingCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        categoryNameTextField.resignFirstResponder()
    }
}

extension EditingCategoryViewController: PassCategoryNamesToEditingVC {
    func getCategoryNameFromPreviuosVC(categoryName: String) {
        categoryNameTextField.text = categoryName
    }
}

//MARK: - SwiftUI
import SwiftUI
struct ProviderEditing : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return EditingCategoryViewController()
        }
        
        typealias UIViewControllerType = UIViewController
        
        
        let viewController = EditingCategoryViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<ProviderEditing.ContainterView>) -> EditingCategoryViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: ProviderEditing.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<ProviderEditing.ContainterView>) {
            
        }
    }
}
