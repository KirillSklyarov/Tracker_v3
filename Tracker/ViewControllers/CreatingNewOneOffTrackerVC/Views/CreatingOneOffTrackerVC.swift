//
//  CreatingOneOffTrackerVC.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingOneOffTrackerVC: UIViewController {
    
    // MARK: - UI Properties
    let trackerNameTextField = UITextField()
    let tableView = UITableView()
    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var cancelButton = setupButtons(title: "Отмена")
    lazy var createButton = setupButtons(title: "Создать")
    lazy var exceedLabel = setupExceedLabel()
    
    let screenScrollView = UIScrollView()
    let contentView = UIView()
    let contentStackView = UIStackView()
    
    // MARK: - Private Properties
    let tableViewRows = ["Категория"]
    
    let arrayOfEmoji = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪",]
    
    let arrayOfColors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4", "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC", "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
    private var newTaskName: String?
    var selectedEmoji: String?
    var selectedColor: String?
    var selectedCategory: String?
    private var selectedSchedule: String?
    
    private let coreDataManager = TrackerCoreManager.shared
    var informAnotherVCofCreatingTracker: ( () -> Void )?
    
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
        informAnotherVCofCreatingTracker?()
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        guard let selectedCategory = selectedCategory,
              let name = trackerNameTextField.text,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else { print("Что-то пошло не так"); return }
        let color = UIColor(hex: selectedColor)
        
        let newTask = TrackerCategory(header: selectedCategory, trackers: [Tracker(id: UUID(), name: name, color: color, emoji: selectedEmoji, schedule: "Пн, Вт, Ср, Чт, Пт, Сб, Вс")])
        coreDataManager.createNewTracker(newTracker: newTask)
        informAnotherVCofCreatingTracker?()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        setupTextField()
        
        setupTableView()
        
        setupEmojiCollectionView()
        
        setupColorsCollectionView()
        
        setupContentStack()
        
        setupScrollView()
        
        self.title = "Новое нерегулярное событие"
        view.backgroundColor = UIColor(named: "projectBackground")
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
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.cornerRadius = 10
    }
    
    private func setupEmojiCollectionView() {
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollection.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiCollection.backgroundColor = .white
        emojiCollection.isScrollEnabled = false
    }
    
    private func setupColorsCollectionView() {
        colorsCollection.dataSource = self
        colorsCollection.delegate = self
        colorsCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorsCell")
        colorsCollection.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        colorsCollection.backgroundColor = .white
        colorsCollection.isScrollEnabled = false
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
    
    private func setupExceedLabel() -> UILabel {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    }
    
    // MARK: - Public Methods
    func isCreateButtonEnable() {
        isAllFieldsFilled() ? createButtonIsActive() : createButtonIsNotActive()
    }
    
    func isAllFieldsFilled() -> Bool {
        let allFieldsFilled = trackerNameTextField.hasText && 
                              selectedCategory != nil &&
                              selectedEmoji != nil &&
                              selectedColor != nil
        return allFieldsFilled
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
    }
    
    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
