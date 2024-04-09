//
//  CreatingOneOffTrackerVC+ScrollView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import UIKit

// MARK: - setupScrollView
extension CreatingOneOffTrackerVC {
    
    func setupScrollView() {
        
        view.addSubViews([screenScrollView])
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let contentView = UIView()
        
        screenScrollView.addSubViews([contentView])
        
        let hConst = contentView.heightAnchor.constraint(equalTo: screenScrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor),
        ])
        
        setupContentStack()
        
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
        
        setupExceedLabel()
        
        let textFieldViewStack = UIStackView()
        textFieldViewStack.axis = .vertical
        textFieldViewStack.spacing = 8
        [trackerNameTextField, exceedLabel].forEach { textFieldViewStack.addArrangedSubview($0) }
         
        let buttonsStack = setupButtonsStack()
                
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalCentering
        
        [textFieldViewStack, contentStackView, tableView, emojiCollection, colorsCollection, buttonsStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false}
        
        [textFieldViewStack, tableView, emojiCollection, colorsCollection, buttonsStack].forEach { contentStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 8),
            colorsCollection.heightAnchor.constraint(equalToConstant: 230),
            
            buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)

        ])
    }
    
    func setupButtonsStack() -> UIStackView {
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "cancelButtonRedColor")?.cgColor
        cancelButton.setTitleColor(UIColor(named: "cancelButtonRedColor"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.setTitleColor(.white, for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(createButton)
        return stack
    }
    
    private func setupExceedLabel() {
        exceedLabel.text = "Ограничение 38 символов"
        exceedLabel.textColor = .red
        exceedLabel.textAlignment = .center
        exceedLabel.font = .systemFont(ofSize: 17, weight: .regular)
        exceedLabel.isHidden = true
    }
}
