//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class CreatingNewHabitViewController: UIViewController {

    private let trackerNameTextField = UITextField()
    private let tableView = UITableView()
    private let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var cancelButton = setupButtons(title: "Отмена")
    private lazy var createButton = setupButtons(title: "Создать")
    private lazy var exceedLabel = setupExceedLabel()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(createButton)
        return stack
    } ()
    
    private let tableViewRows = ["Категории", "Расписание"]
    
    private let arrayOfEmoji = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪",]
    
    private let arrayOfColors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4", "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC", "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        setupCollectionView()
        
        setupUI()
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
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.cornerRadius = 10
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    private func setupCollectionView() {
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        emojiCollection.register(SuplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")

        emojiCollection.backgroundColor = .white
    }
    
    private func setupUI() {
        
        setupTextField()
    
        self.title = "Новая привычка"
        view.backgroundColor = UIColor(named: "projectBackground")
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "cancelButtonRedColor")?.cgColor
        cancelButton.setTitleColor(UIColor(named: "cancelButtonRedColor"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.backgroundColor = UIColor(named: "createButtonGrayColor")
        createButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let viewStack = UIStackView()
        viewStack.axis = .vertical
        viewStack.spacing = 10
        viewStack.addArrangedSubview(trackerNameTextField)
        viewStack.addArrangedSubview(exceedLabel)
        
        view.addSubViews([viewStack, tableView, emojiCollection, buttonsStack])

        NSLayoutConstraint.activate([
            viewStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            viewStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            viewStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: viewStack.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableViewRows.count) * 75),
            
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            emojiCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor,
            constant: 18),
            emojiCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            emojiCollection.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -16),
                        
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped(_ sender: UIButton) {
        print("We'are here too")
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

extension CreatingNewHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
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
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableViewRows[indexPath.row]
        if data == "Расписание" {
            let scheduleVC = ScheduleViewController()
            let navVC = UINavigationController(rootViewController: scheduleVC)
            scheduleVC.scheduleToPass = { [weak self] schedule in
                guard let self = self,
                    let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = schedule
            }
            present(navVC, animated: true)
        } else {
            let categoryVC = ChoosingCategoryViewController()
            let navVC = UINavigationController(rootViewController: categoryVC)
            categoryVC.updateCategory = { [weak self] categoryName in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = categoryName
            }
            present(navVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CreatingNewHabitViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount <= 25 {
            hideLabelExceedTextFieldLimit()
            textField.textColor = .black
            return true
        } else {
            print("Check: opps")
            showLabelExceedTextFieldLimit()
            textField.textColor = .red
            return true
        }
    }
}

extension CreatingNewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            arrayOfEmoji.count
        } else {
            arrayOfColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        
        if indexPath.section == 0 {
            let view = UILabel(frame: cell.contentView.bounds)
            view.text = arrayOfEmoji[indexPath.row]
            view.font = .systemFont(ofSize: 32)
            view.textAlignment = .center
            cell.addSubview(view)
        } else {
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            view.layer.cornerRadius = 8
            let colors = colorFromHexToRGB(hexColors: arrayOfColors)
            view.backgroundColor = colors[indexPath.row]
            cell.contentView.addSubview(view)
            view.center = CGPoint(x: cell.contentView.bounds.midX,
                                  y: cell.contentView.bounds.midY)
            
        }
        return cell
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
        CGSize(width: collectionView.frame.width, height: 18)
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
        if indexPath.section == 0 {
            view.label.text = "Emoji"
        } else {
            view.label.text = "Цвет"
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 38, left: 0, bottom: 0, right: 0)
    }
}


//MARK: - SwiftUI
import SwiftUI
struct Provider2 : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return CreatingNewHabitViewController()
        }
        
        typealias UIViewControllerType = UIViewController
        
        
        let viewController = CreatingNewHabitViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<Provider2.ContainterView>) -> CreatingNewHabitViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: Provider2.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<Provider2.ContainterView>) {
            
        }
    }
}
