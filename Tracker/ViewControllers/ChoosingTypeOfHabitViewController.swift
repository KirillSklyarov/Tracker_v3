//
//  CreatingNewHabitViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class ChoosingTypeOfHabitViewController: UIViewController {

    private lazy var creatingHabitButton = setupButtons(title: "Привычка")
    private lazy var creatingEventButton = setupButtons(title: "Нерегулярные события")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
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
    
    @objc private func creatingHabitButtonTapped(_ sender: UIButton) {
          print("We'are here")
        let creatingNewHabit = CreatingNewHabitViewController()
        let creatingNavVC = UINavigationController(rootViewController: creatingNewHabit)
        present(creatingNavVC, animated: true)
    }
    
    @objc private func creatingEventButtonTapped(_ sender: UIButton) {
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
        return button
    }
    
}


//MARK: - SwiftUI
import SwiftUI
struct Provider1 : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return ChoosingTypeOfHabitViewController()
        }
        
        typealias UIViewControllerType = UIViewController
        
        
        let viewController = ChoosingTypeOfHabitViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<Provider1.ContainterView>) -> ChoosingTypeOfHabitViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: Provider1.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<Provider1.ContainterView>) {
            
        }
    }
}
