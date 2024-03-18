//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingCategoryViewController: UIViewController {

    private let creatingCategoryButton = UIButton()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        showPlaceholderForEmptyScreen()
        
        
    }
    
    private func setupUI() {
        
        self.title = "Категория"
        
        setupButton()
        
        view.backgroundColor = .systemBackground
        view.addSubViews([creatingCategoryButton])
        
        NSLayoutConstraint.activate([
            creatingCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creatingCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            creatingCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            creatingCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
        ])
    }
    
    private func showPlaceholderForEmptyScreen() {
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
        
        let categories = TrackerViewController().categories

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
