//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingCategoryViewController: UIViewController {
    
    // MARK: - UI Properties
    private let creatingCategoryButton = UIButton()
    private let categoryTableView = UITableView()
    private lazy var swooshImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "swoosh")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        image.contentMode = .center
        return image
    } ()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \nобъединить по смыслу"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()
    
    // MARK: - Private Properties
    private let coreDataManager = TrackerCoreManager.shared
    private var delegateToPassCategoryNameToEdit: PassCategoryNamesToEditingVC?
    private var categories = [String]()
    
//    private var lastChosenCategory: String?
    
    var updateCategory: ( (String) -> Void)?
    
    
    // MARK: - Live Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromCoreData()
        
        setupUI()
        setupTableView()
        
//        print("lastChosenCategory \(lastChosenCategory)")
        
    }
    
    // MARK: - IB Actions
    @objc private func addCategoryButtonTapped(_ sender: UIButton) {
        let creatingNewCategoryVC = CreatingNewCategoryViewController()
        let creatingCategoryNavVC = UINavigationController(rootViewController: creatingNewCategoryVC)
        creatingNewCategoryVC.updateTableClosure = { [weak self] newCategory in
            guard let self = self else { return }
            coreDataManager.createNewCategory(newCategoryName: newCategory)
            getDataFromCoreData()
            designFirstAndLastCell()
            
            if categories.isEmpty {
                showPlaceholderForEmptyScreen()
            } else {
                swooshImage.isHidden = true
                textLabel.isHidden = true
            }
        }
        present(creatingCategoryNavVC, animated: true)
    }
    
    // MARK: - Private Methods
    private func setupTableView() {
        
        showPlaceholderForEmptyScreen()
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        categoryTableView.layer.cornerRadius = 16
        categoryTableView.tableHeaderView = UIView()
    }
    
    private func setupUI() {
        
        self.title = "Категория"
        setupButton()
        view.backgroundColor = .systemBackground
        view.addSubViews([categoryTableView, creatingCategoryButton])
        
        NSLayoutConstraint.activate([
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: creatingCategoryButton.topAnchor, constant: -20),
            
            creatingCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creatingCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            creatingCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            creatingCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func showPlaceholderForEmptyScreen() {
        
        let emptyScreenStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .center
            
            stack.addArrangedSubview(swooshImage)
            stack.addArrangedSubview(textLabel)
            return stack
        } ()
        
        if categories.isEmpty {
            swooshImage.isHidden = false
            textLabel.isHidden = false
        } else {
            swooshImage.isHidden = true
            textLabel.isHidden = true
        }
        
        view.addSubViews([emptyScreenStack])
        
        NSLayoutConstraint.activate([
            emptyScreenStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupButton() {
        creatingCategoryButton.setTitle("Добавить категорию", for: .normal)
        creatingCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        creatingCategoryButton.setTitleColor(.white, for: .normal)
        creatingCategoryButton.backgroundColor = .black
        creatingCategoryButton.layer.masksToBounds = true
        creatingCategoryButton.layer.cornerRadius = 15
        
        creatingCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ChoosingCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = categories[indexPath.row]
        
        let lastChosenCategory = coreDataManager.getLastChosenCategoryFromStore()
        
        if lastChosenCategory == cell.textLabel?.text {
            let selectionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
            selectionImage.image = UIImage(named: "bluecheckmark")
            cell.accessoryView = selectionImage
        }
                
        if indexPath.row == categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        let selectionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        selectionImage.image = UIImage(named: "bluecheckmark")
        cell?.accessoryView = selectionImage
        
        guard let categoryNameToPass = cell?.textLabel?.text else { return }
        
        coreDataManager.sendLastChosenCategoryToStore(categoryName: categoryNameToPass)

        updateCategory?(categoryNameToPass)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIView()
    }
}

// MARK: - Context Menu
extension ChoosingCategoryViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider:
                                            { _ in return self.showContextMenu(indexPath: indexPath) }
        )
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
    }
    
    func showContextMenu(indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(title: "Редактировать") { [weak self] _ in
            guard let self = self,
                  let cell = self.categoryTableView.cellForRow(at: indexPath),
                  let categoryNameToPass = cell.textLabel?.text else { return }
            let editingVC = EditingCategoryViewController()
            let navVC = UINavigationController(rootViewController: editingVC)
            self.delegateToPassCategoryNameToEdit = editingVC
            delegateToPassCategoryNameToEdit?.getCategoryNameFromPreviousVC(categoryName: categoryNameToPass)
            
            editingVC.updateCategoryNameClosure = {
                self.getDataFromCoreData()
            }
            present(navVC, animated: true)
        }
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
            self.showAlert(indexPath: indexPath)
        }
        return UIMenu(children: [editAction, deleteAction])
    }
    
    private func showAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Эта категория точно не нужна", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let cell = self.categoryTableView.cellForRow(at: indexPath),
                  let categoryNameToDelete = cell.textLabel?.text else { return }
            self.coreDataManager.deleteCategory(header: categoryNameToDelete)
            self.getDataFromCoreData()
            self.designFirstAndLastCell()
            self.showPlaceholderForEmptyScreen()
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    private func designFirstAndLastCell() {
        let indexPathOfFirstCell = IndexPath(row: 0, section: 0)
        let indexPathOfLastCell = IndexPath(row: self.categories.count - 1, section: 0)
        
        guard let firstCell = self.categoryTableView.cellForRow(at: indexPathOfFirstCell),
              let lastCell = self.categoryTableView.cellForRow(at: indexPathOfLastCell) else { return }
        
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        firstCell.layer.cornerRadius = 16
        firstCell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        firstCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        lastCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        lastCell.layer.cornerRadius = 16
        lastCell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}

// MARK: - Update data from Core Data
private extension ChoosingCategoryViewController {
    
    func getDataFromCoreData() {
        self.categories = coreDataManager.getCategoryNamesFromStorage()
        self.categoryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}
