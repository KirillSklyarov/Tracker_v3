//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingCategoryViewController: BaseViewController {
    
    // MARK: - UI Properties
    private lazy var creatingCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    } ()
    private lazy var swooshImage: UIImageView = {
        let swoosh = UIImageView()
        swoosh.image = UIImage(named: "swoosh")
        swoosh.contentMode = .center
        return swoosh
    } ()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \nобъединить по смыслу"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    } ()
    
    let categoryTableView = UITableView()
    
    // MARK: - Public Properties
    let rowHeight = CGFloat(75)
    
    // MARK: - Live Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBinding()
        
        getDataFromViewModel()
        
        setupUI()
        
        showOrHidePlaceholder()
        
    }
    
    private func getDataFromViewModel() {
        viewModel.getDataFromCoreData()
    }
    
    // MARK: - IB Actions
    @objc private func addCategoryButtonTapped(_ sender: UIButton) {
        let viewModel = ChoosingCategoryViewModel()
        let creatingNewCategoryVC = CreatingNewCategoryViewController(viewModel: viewModel)
        let creatingCategoryNavVC = UINavigationController(rootViewController: creatingNewCategoryVC)
        
        
        creatingNewCategoryVC.viewModel.updateCategory = { [weak self] newCategory in
            guard let self = self else { return }
            self.viewModel.createNewCategory(newCategoryName: newCategory)
            showOrHidePlaceholder()
        }
        present(creatingCategoryNavVC, animated: true)
    }
    
    // MARK: - Private Methods
    private func setupBinding() {
        viewModel.dataUpdated = { [weak self] in
            guard let self else { return }
            self.categoryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    private func setupUI() {
        
        setupTableView()
        
        self.title = "Категория"
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
    
    // MARK: - Setup Placeholder
    func showOrHidePlaceholder() {
        viewModel.categories.isEmpty ? showPlaceholder() : hidePlaceholder()
    }
    
    private func showPlaceholder() {
        
        swooshImage.isHidden = false
        textLabel.isHidden = false
        
        let emptyScreenStack = UIStackView()
        emptyScreenStack.axis = .vertical
        emptyScreenStack.spacing = 8
        emptyScreenStack.alignment = .center
        
        [swooshImage, textLabel].forEach { emptyScreenStack.addArrangedSubview($0) }
        
        view.addSubViews([emptyScreenStack])
        
        NSLayoutConstraint.activate([
            emptyScreenStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            swooshImage.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func hidePlaceholder() {
        swooshImage.isHidden = true
        textLabel.isHidden = true
    }
}
