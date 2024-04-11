//
//  CreatingNewTrackerViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingNewTrackerViewController: UIViewController {
    
    // MARK: - UI Properties
    let trackerNameTextField = UITextField()
    let tableView = UITableView()
    let exceedLabel = UILabel()
    
    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var cancelButton = setupButtons(title: "Отмена")
    lazy var createButton = setupButtons(title: "Создать")
    
    let contentStackView = UIStackView()
    
    // MARK: - Private Properties
    let viewModel = CreatingNewTrackerViewModel()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        isCreateButtonEnable()
        
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - IB Actions
    @objc func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        isCreateButtonEnable()
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        viewModel.informAnotherVCofCreatingTracker?()
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        guard let name = trackerNameTextField.text else { print("Что-то пошло не так"); return }
        viewModel.createNewTask(trackerNameTextField: name)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        setupTextField()
        setupContentStack()
        
        setupTableView()
        
        setupEmojiCollectionView()
        
        setupColorsCollectionView()
        
        self.title = "Новая привычка"
        view.backgroundColor = UIColor(named: "projectBackground")
        
        setupScrollView()
    }
    
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
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
        
        lazy var clearTextStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.addArrangedSubview(clearTextFieldButton)
            stack.addArrangedSubview(rightPaddingView)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.widthAnchor.constraint(equalToConstant: 28).isActive = true
            return stack
        } ()
        
        trackerNameTextField.placeholder = "Введите название трекера"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        trackerNameTextField.leftView = leftPaddingView
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.rightView = clearTextStack
        trackerNameTextField.rightViewMode = .whileEditing
        trackerNameTextField.textAlignment = .left
        trackerNameTextField.layer.cornerRadius = 10
        trackerNameTextField.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        trackerNameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        trackerNameTextField.delegate = self
    }
    
    func isCreateButtonEnable() {
        isAllFieldsFilled() ? createButtonIsActive() : createButtonIsNotActive()
    }
    
    func isAllFieldsFilled() -> Bool {
        let textFieldTest = trackerNameTextField.hasText
        return viewModel.isAllFieldsFilled(trackerNameTextField: textFieldTest)
    }
    
    func createButtonIsActive() {
        createButton.isEnabled = true
        createButton.backgroundColor = .black
    }
    
    func createButtonIsNotActive() {
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(named: "createButtonGrayColor")
    }
    
    func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
        exceedLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
