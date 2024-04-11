//
//  EditingTrackerVC.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 03.04.2024.
//

import UIKit

final class EditingTrackerViewController: UIViewController {
    
    // MARK: - UI Properties
    lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.text = viewModel.countOfCompletedDays
        return label
    } ()
    lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.text = viewModel.trackerName
        textField.placeholder = "Введите название трекера"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.delegate = self
        return textField
    } ()
    lazy var cancelButton = setupButtons(title: "Отмена")
    lazy var saveButton = setupButtons(title: "Сохранить")
    lazy var exceedLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    } ()
    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        return stack
    } ()
    
    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let tableView = UITableView()
    let rowHeight = CGFloat(75)
    
    // MARK: - Public Properties
    var viewModel: EditingTrackerViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: EditingTrackerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataBinding()
        
        setupUI()
        
        //        isCreateButtonEnable()
        
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - IB Actions
    
    func dataBinding() {
        viewModel.updateSaveButton = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async { [self] in
                self.isCreateButtonEnable()
            }
        }
    }
    
    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        isCreateButtonEnable()
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        viewModel.updateTracker()
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
        trackerNameTextField.rightViewMode = .whileEditing
    }
    
    func isCreateButtonEnable() {
        viewModel.isAllFieldsFilled() ? saveButtonIsActive() : saveButtonIsNotActive()
    }
    
    func saveButtonIsActive() {
        saveButton.isEnabled = true
        saveButton.backgroundColor = .black
    }
    
    func saveButtonIsNotActive() {
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor(named: "createButtonGrayColor")
    }
    
    private func setupUI() {
        
        self.title = "Редактирование привычки"
        view.backgroundColor = UIColor(named: "projectBackground")
        
        setupTextField()
        setupContentStack()
        setupScrollView()
        setupTableView()
        setupEmojiCollectionView()
        setupColorsCollectionView()
        
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
    
    func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
    }
    
    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
