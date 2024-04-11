//
//  CreatingOneOffTrackerVC.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingOneOffTrackerVC: UIViewController {
    
    // MARK: - UI Properties
    lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.rightViewMode = .whileEditing
        textField.textAlignment = .left
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor(named: "textFieldBackgroundColor")
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
    
    lazy var cancelButton = setupButtons(title: "Отмена")
    lazy var createButton = setupButtons(title: "Создать")
    
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
    var viewModel: CreatingOneOffTrackerViewModelProtocol
    
    init(viewModel: CreatingOneOffTrackerViewModelProtocol) {
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
        viewModel.informAnotherVCofCreatingTracker?()
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        viewModel.createNewTracker()
    }
    
    // MARK: - UI Methods
    private func setupUI() {
        
        createButtonIsNotActive()
        
        setupTextField()
        
        setupTableView()
        
        setupEmojiCollectionView()
        
        setupColorsCollectionView()
        
        setupScrollView()
        
        title = "Новое нерегулярное событие"
        view.backgroundColor = UIColor(named: "projectBackground")
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
    
    private func createButtonIsActive() {
        createButton.isEnabled = true
        createButton.backgroundColor = .black
    }
    
    private func createButtonIsNotActive() {
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
    
    // MARK: - Private Methods
    private func dataBinding() {
        viewModel.isDoneButtonEnable = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.viewModel.isAllFieldsFilled() ? self.createButtonIsActive() : self.createButtonIsNotActive()
            }
        }
    }
}
