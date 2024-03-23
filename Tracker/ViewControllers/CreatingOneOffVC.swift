//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingOneOffVC: UIViewController {
    
    private let trackerNameTextField = UITextField()
    private let tableView = UITableView()
    private let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var cancelButton = setupButtons(title: "Отмена")
    private lazy var createButton = setupButtons(title: "Создать")
    private lazy var exceedLabel = setupExceedLabel()
    
    private let screenScrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    
    private let tableViewRows = ["Категория"]
    
    private let arrayOfEmoji = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪",]
    
    private let arrayOfColors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4", "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC", "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
    private var newTaskName: String?
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory: String?
    private var selectedSchedule: String?
    
    var newTaskToPassToMainScreen: ( (TrackerCategory) -> Void )?
    
    let categoryStorage = CategoryStorage.shared
    
    var delegate: NewTaskDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupTableView()
        
        setupEmojiCollectionView()
        
        setupColorsCollectionView()
        
        isCreateButtonEnable()
        
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
    
    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        isCreateButtonEnable()
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
    
    private func isCreateButtonEnable() {
        if let text = trackerNameTextField.text, !text.isEmpty,
           selectedCategory != nil,
           selectedEmoji != nil,
           selectedColor != nil {
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            print("New task name \(String(describing: trackerNameTextField.text))")
            print("Selected category \(String(describing: selectedCategory))")
            print("Selected schedule \(String(describing: selectedSchedule))")
            print("Selected Emoji \(String(describing: selectedEmoji))")
            print("Selected Color \(String(describing: selectedColor))")
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "createButtonGrayColor")
        }
    }
    
    private func setupUI() {
        
        setupTextField()
        setupContentStack()
        
        self.title = "Новое нерегулярное событие"
        view.backgroundColor = UIColor(named: "projectBackground")
        
        setupScrollView()
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped(_ sender: UIButton) {
        print("We'are here too")
        guard let selectedCategory = selectedCategory,
              let name = trackerNameTextField.text,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else { print("Что-то пошло не так"); return }
        let color = UIColor(hex: selectedColor)
        
        let newTask = TrackerCategory(header: selectedCategory, trackers: [Tracker(id: UUID(), name: name, color: color, emoji: selectedEmoji, schedule: "Пн, Вт, Ср, Чт, Пт, Сб, Вс")])
        print(newTask)
        newTaskToPassToMainScreen?(newTask)
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        categoryStorage.addToDataBase(dataBase: newTask)
        present(tabBarVC, animated: true)
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
    
    private func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
    }
    
    private func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}

extension CreatingOneOffVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = tableViewRows[indexPath.row]
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = UIColor(named: "createButtonGrayColor")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.selectionStyle = .none
        
        let disclosureImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 7, height: 12))
        disclosureImage.image = UIImage(named: "chevron")
        cell.accessoryView = disclosureImage
        
        if indexPath.row == tableViewRows.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryVC = ChoosingCategoryViewController()
        let navVC = UINavigationController(rootViewController: categoryVC)
        categoryVC.updateCategory = { [weak self] categoryName in
            guard let self = self,
                  let cell = tableView.cellForRow(at: indexPath) else { return }
            cell.detailTextLabel?.text = categoryName
            self.selectedCategory = categoryName
            self.isCreateButtonEnable()
        }
        present(navVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CreatingOneOffVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount <= 25 {
            hideLabelExceedTextFieldLimit()
            isCreateButtonEnable()
            textField.textColor = .black
            return true
        } else {
            print("Check: opps")
            showLabelExceedTextFieldLimit()
            textField.textColor = .red
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNameTextField.resignFirstResponder()
    }
}

extension CreatingOneOffVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollection {
            arrayOfEmoji.count
        } else {
            arrayOfColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == emojiCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let view = UILabel(frame: cell.contentView.bounds)
            view.text = arrayOfEmoji[indexPath.row]
            view.font = .systemFont(ofSize: 32)
            view.textAlignment = .center
            cell.addSubview(view)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorsCell", for: indexPath)
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            view.layer.cornerRadius = 8
            let colors = colorFromHexToRGB(hexColors: arrayOfColors)
            view.backgroundColor = colors[indexPath.row]
            cell.contentView.addSubview(view)
            view.center = CGPoint(x: cell.contentView.bounds.midX,
                                  y: cell.contentView.bounds.midY)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollection {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.cornerRadius = 8
            cell?.backgroundColor = UIColor(named: "textFieldBackgroundColor")
            selectedEmoji = arrayOfEmoji[indexPath.row]
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3
            let colors = colorFromHexToRGB(hexColors: arrayOfColors)
            let cellColor = colors[indexPath.row].withAlphaComponent(0.3)
            cell?.layer.borderColor = cellColor.cgColor
            cell?.layer.cornerRadius = 8
            selectedColor = arrayOfColors[indexPath.row]
        }
        isCreateButtonEnable()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollection {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = .clear
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0
        }
    }
    
    private func colorFromHexToRGB(hexColors: [String]) -> [UIColor] {
        return hexColors.map { UIColor(hex: $0) }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SuplementaryView
        if collectionView == emojiCollection {
            view.label.text = "Emoji"
        } else {
            view.label.text = "Цвет"
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
}

private extension CreatingOneOffVC {
    
    func setupScrollView() {
        view.addSubViews([screenScrollView])
        
        screenScrollView.addSubViews([contentView])
        
        let hConst = contentView.heightAnchor.constraint(equalTo: screenScrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor),
        ])
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    func setupContentStack() {
        
        let textFieldViewStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(trackerNameTextField)
            stack.addArrangedSubview(exceedLabel)
            return stack
        } ()
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "cancelButtonRedColor")?.cgColor
        cancelButton.setTitleColor(UIColor(named: "cancelButtonRedColor"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.setTitleColor(.white, for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let buttonsStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 8
            stack.addArrangedSubview(cancelButton)
            stack.addArrangedSubview(createButton)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
            return stack
        } ()
        
        
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalCentering
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        colorsCollection.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(textFieldViewStack)
        contentStackView.addArrangedSubview(tableView)
        contentStackView.addArrangedSubview(emojiCollection)
        contentStackView.addArrangedSubview(colorsCollection)
        contentStackView.addArrangedSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            textFieldViewStack.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            textFieldViewStack.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            textFieldViewStack.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            textFieldViewStack.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            emojiCollection.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 8),
            colorsCollection.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            colorsCollection.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            colorsCollection.heightAnchor.constraint(equalToConstant: 230),
            
            buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 16),
            buttonsStack.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor)
        ])
    }
    
}


//MARK: - SwiftUI
import SwiftUI
struct Provider4 : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return CreatingOneOffVC()
        }
        
        typealias UIViewControllerType = UIViewController
        
        
        let viewController = CreatingOneOffVC()
        func makeUIViewController(context: UIViewControllerRepresentableContext<Provider4.ContainterView>) -> CreatingOneOffVC {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: Provider4.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<Provider4.ContainterView>) {
            
        }
    }
}
