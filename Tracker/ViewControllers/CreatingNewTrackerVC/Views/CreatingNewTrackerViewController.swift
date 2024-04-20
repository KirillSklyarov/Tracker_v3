//
//  CreatingNewTrackerViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingNewTrackerViewController: UIViewController {
    
    // MARK: - UI Properties
    lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = SGen.enterTrackerSName
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.rightViewMode = .whileEditing
        textField.layer.cornerRadius = 10
        textField.backgroundColor = AppColors.textFieldBackground
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.delegate = self
        return textField
    } ()
    lazy var exceedLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    } ()
    lazy var cancelButton = setupButtons(title: SGen.cancel)
    lazy var createButton = setupButtons(title: SGen.create)
    
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
    
    // MARK: - Private Properties
    var viewModel: CreatingNewTrackerViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: CreatingNewTrackerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        dataBinding()
        
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - IB Actions
    @objc func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        viewModel.trackerName = ""
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        viewModel.getBackToMainScreen()
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        viewModel.createNewTracker()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        self.title = SGen.newTracker
        view.backgroundColor = AppColors.background
                
        createButtonIsNotActive()
        
        setupTextField()
        
        setupContentStack()
        
        setupTableView()
        
        setupEmojiCollectionView()
        
        setupColorsCollectionView()
        
        setupScrollView()
    }
    
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(AppColors.buttonTextColor, for: .normal)
        button.backgroundColor = AppColors.buttonBlack
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
            let imageColor = AppColors.buttonGray ?? .lightGray
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
        trackerNameTextField.textAlignment = .left
        trackerNameTextField.textColor = AppColors.textFieldTextColor
    }
    
    // MARK: - Private Methods
    private func dataBinding() {
        viewModel.isDoneButtonEnable = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.viewModel.isAllFieldsFilled() ? self.createButtonIsActive() : self.createButtonIsNotActive()
            }
        }
    }
    
    func createButtonIsActive() {
        createButton.isEnabled = true
        createButton.backgroundColor = AppColors.buttonBlack
    }
    
    func createButtonIsNotActive() {
        createButton.isEnabled = false
        createButton.backgroundColor = AppColors.buttonGray
        createButton.setTitleColor(AppColors.createButtonText, for: .disabled)
    }
    
    func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
        exceedLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
