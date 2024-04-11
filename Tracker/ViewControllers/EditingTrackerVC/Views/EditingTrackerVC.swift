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
        return label
    } ()
    lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
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
        
        setupUI()
        
        setupTableView()
        
        setupEmojiCollectionView()
        
        setupColorsCollectionView()
        
        isCreateButtonEnable()
        
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - IB Actions
    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        isCreateButtonEnable()
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        guard let selectedCategory = viewModel.selectedCategory,
              let name = trackerNameTextField.text,
              let selectedColor = viewModel.selectedColor,
              let selectedEmoji = viewModel.selectedEmoji,
              let selectedSchedule = viewModel.selectedSchedule else { print("Что-то пошло не так"); return }
        let color = selectedColor
        
        let newTask = TrackerCategory(header: selectedCategory, trackers: [Tracker(id: UUID(), name: name, color: color, emoji: selectedEmoji, schedule: selectedSchedule)])
        viewModel.coreDataManager.createNewTracker(newTracker: newTask)
        viewModel.informAnotherVCofCreatingTracker?()
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
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.cornerRadius = 10
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
    }
    
    private func setupEmojiCollectionView() {
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiCollection.backgroundColor = .white
        emojiCollection.isScrollEnabled = false
    }
    
    private func setupColorsCollectionView() {
        colorsCollection.dataSource = self
        colorsCollection.delegate = self
        colorsCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorsCell")
        colorsCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        colorsCollection.backgroundColor = .white
        colorsCollection.isScrollEnabled = false
    }
    
    func isCreateButtonEnable() {
        if let text = trackerNameTextField.text, !text.isEmpty,
           viewModel.selectedCategory != nil,
           viewModel.selectedSchedule != nil,
           viewModel.selectedEmoji != nil,
           viewModel.selectedColor != nil {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .black
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor(named: "createButtonGrayColor")
        }
    }
    
    private func setupUI() {
        
        setupTextField()
        setupContentStack()
        
        self.title = "Редактирование привычки"
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
    
    func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
    }
    
    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
