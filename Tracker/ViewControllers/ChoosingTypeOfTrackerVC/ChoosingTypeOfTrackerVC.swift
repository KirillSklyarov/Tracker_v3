//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingTypeOfTrackerViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var creatingTrackerButton = setupButtons(title: SGen.tracker)
    private lazy var creatingEventButton = setupButtons(title: SGen.oneTimeEvent)
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    // MARK: - IB Actions
    @objc private func creatingTrackerButtonTapped(_ sender: UIButton) {
        let viewModel = CreatingNewTrackerViewModel()
        let creatingNewTracker = CreatingNewTrackerViewController(viewModel: viewModel)
        let creatingNavVC = UINavigationController(rootViewController: creatingNewTracker)
        present(creatingNavVC, animated: true)
    }
    
    @objc private func creatingEventButtonTapped(_ sender: UIButton) {
        let viewModel = CreatingOneOffTrackerViewModel()
        let creatingOneOffEvent = CreatingOneOffTrackerVC(viewModel: viewModel)
        let creatingNavVC = UINavigationController(rootViewController: creatingOneOffEvent)
        present(creatingNavVC, animated: true)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        self.title = SGen.creatingATracker
        view.backgroundColor = AppColors.background
        
        creatingTrackerButton.addTarget(self, action: #selector(creatingTrackerButtonTapped), for: .touchUpInside)
        creatingEventButton.addTarget(self, action: #selector(creatingEventButtonTapped), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [creatingTrackerButton, creatingEventButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        
        view.addSubViews([buttonStack])
        
        NSLayoutConstraint.activate([
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(AppColors.buttonTextColor, for: .normal)
        button.backgroundColor = AppColors.buttonBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }
    
}
