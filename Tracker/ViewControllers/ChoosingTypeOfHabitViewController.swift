//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingTypeOfHabitViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var creatingHabitButton = setupButtons(title: "Привычка")
    private lazy var creatingEventButton = setupButtons(title: "Нерегулярные события")
    
    // MARK: - Other Properties
    weak var closeScreenDelegate: CloseScreenDelegate?
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

    }
    
    // MARK: - IB Actions
    @objc private func creatingHabitButtonTapped(_ sender: UIButton) {
        let creatingNewHabit = CreatingNewHabitViewController()
        let creatingNavVC = UINavigationController(rootViewController: creatingNewHabit)
        present(creatingNavVC, animated: true)
        
        creatingNewHabit.informAnotherVCofCreatingTracker = {
            self.closeScreenDelegate?.closeFewVCAfterCreatingTracker()
        }
    }
    
    @objc private func creatingEventButtonTapped(_ sender: UIButton) {
        let creatingOneOffEvent = CreatingOneOffVC()
        let creatingNavVC = UINavigationController(rootViewController: creatingOneOffEvent)
        present(creatingNavVC, animated: true)
        
        creatingOneOffEvent.informAnotherVCofCreatingTracker = {
            self.closeScreenDelegate?.closeFewVCAfterCreatingTracker()
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        self.title = "Создание трекера"
        
        creatingHabitButton.addTarget(self, action: #selector(creatingHabitButtonTapped), for: .touchUpInside)
        creatingEventButton.addTarget(self, action: #selector(creatingEventButtonTapped), for: .touchUpInside)
        
        view.backgroundColor = .systemBackground
        view.addSubViews([creatingHabitButton, creatingEventButton])
        
        NSLayoutConstraint.activate([
            creatingHabitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 281),
            creatingHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creatingHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            creatingHabitButton.heightAnchor.constraint(equalToConstant: 60),
            
            creatingEventButton.topAnchor.constraint(equalTo: creatingHabitButton.bottomAnchor, constant: 16),
            creatingEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creatingEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            creatingEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        return button
    }
    
}
