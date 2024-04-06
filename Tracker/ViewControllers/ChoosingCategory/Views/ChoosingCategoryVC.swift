//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingCategoryViewController: UIViewController {
    
    // MARK: - UI Properties
    let creatingCategoryButton = UIButton()
    let categoryTableView = UITableView()
    let swooshImage = UIImageView()
    let textLabel = UILabel()
    
    // MARK: - Public Properties
    let viewModel = ChoosingCategoryViewModel()
    
    var updateCategory: ( (String) -> Void)?
    
    // MARK: - Live Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getDataFromCoreData()
        
        setupUI()
        
        showOrHidePlaceholder()
        
    }
    
    // MARK: - IB Actions
    @objc private func addCategoryButtonTapped(_ sender: UIButton) {
        let creatingNewCategoryVC = CreatingNewCategoryViewController()
        let creatingCategoryNavVC = UINavigationController(rootViewController: creatingNewCategoryVC)
        creatingNewCategoryVC.updateTableClosure = { [weak self] newCategory in
            guard let self = self else { return }
            viewModel.createNewCategory(newCategoryName: newCategory)
            
            viewModel.dataUpdated = {
                self.categoryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.designFirstAndLastCell()

            }
            
            viewModel.getDataFromCoreData()
            
            
            showOrHidePlaceholder()
            
        }
        present(creatingCategoryNavVC, animated: true)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        setupTableView()
        
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
    
    private func showOrHidePlaceholder() {
        viewModel.categories.isEmpty ? showPlaceholderForEmptyScreen() : hidePlaceholder()
    }
    
    func showPlaceholderForEmptyScreen() {
        
        swooshImage.image = UIImage(named: "swoosh")
        swooshImage.translatesAutoresizingMaskIntoConstraints = false
        swooshImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        swooshImage.contentMode = .center
        
        textLabel.text = "Привычки и события можно \nобъединить по смыслу"
        textLabel.numberOfLines = 0
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyScreenStack = UIStackView()
        emptyScreenStack.axis = .vertical
        emptyScreenStack.spacing = 8
        emptyScreenStack.alignment = .center
        
        emptyScreenStack.addArrangedSubview(swooshImage)
        emptyScreenStack.addArrangedSubview(textLabel)
        
        view.addSubViews([emptyScreenStack])
        
        NSLayoutConstraint.activate([
            emptyScreenStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func hidePlaceholder() {
        swooshImage.isHidden = true
        textLabel.isHidden = true
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
