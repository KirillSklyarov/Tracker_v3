//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingCategoryViewController: UIViewController {

    private let creatingCategoryButton = UIButton()
    private let categoryTableView = UITableView()
    let swooshImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "swoosh")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        image.contentMode = .center
        return image
    } ()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \nобъединить по смыслу"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()
    
    var categories: [TrackerCategory] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupTableView()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Check: \(categories)")
        if categories.isEmpty {
            showPlaceholderForEmptyScreen()
        } else {
            swooshImage.isHidden = true
            textLabel.isHidden = true
        }
    }
    
    private func setupTableView() {
        
        showPlaceholderForEmptyScreen()
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            
        categoryTableView.layer.cornerRadius = 10
        categoryTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    
    private func setupUI() {
        
        let rowHeight = CGFloat(75)
        
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
    
    @objc private func creatingCategoryButtonTapped(_ sender: UIButton) {
        let creatingNewCategoryVC = CreatingNewCategoryViewController()
        let creatingCategoryNavVC = UINavigationController(rootViewController: creatingNewCategoryVC)
        creatingNewCategoryVC.updateTableClosure = { [weak self] newCategory in
            guard let self = self else { return }
            self.categories.append(newCategory)
            self.categoryTableView.reloadData()
            categoryTableView.heightAnchor.constraint(equalToConstant: 75 * CGFloat(categories.count)).isActive = true
            categoryTableView.layoutIfNeeded()
            
            if categories.isEmpty {
                showPlaceholderForEmptyScreen()
            } else {
                swooshImage.isHidden = true
                textLabel.isHidden = true
            }
            
            print(self.categories)
            print(self.categories.count)
        }
        present(creatingCategoryNavVC, animated: true)
    }
    
    private func setupButton() {
        creatingCategoryButton.setTitle("Добавить категорию", for: .normal)
        creatingCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        creatingCategoryButton.setTitleColor(.white, for: .normal)
        creatingCategoryButton.backgroundColor = .black
        creatingCategoryButton.layer.masksToBounds = true
        creatingCategoryButton.layer.cornerRadius = 15
        
        creatingCategoryButton.addTarget(self, action: #selector(creatingCategoryButtonTapped), for: .touchUpInside)
    }
}

extension ChoosingCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
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
        cell.textLabel?.text = categories[indexPath.row].header
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        dismiss(animated: true)
    }
}

//MARK: - SwiftUI
import SwiftUI
struct ProviderChoosingCategory : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return ChoosingCategoryViewController()
        }
        
        typealias UIViewControllerType = UIViewController
        
        
        let viewController = ChoosingCategoryViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<ProviderChoosingCategory.ContainterView>) -> ChoosingCategoryViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: ProviderChoosingCategory.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<ProviderChoosingCategory.ContainterView>) {
            
        }
    }
}
