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
        
        screenScrollView.addSubViews([contentView])
        
        let hConst = contentView.heightAnchor.constraint(equalTo: screenScrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor),
        ])
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
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
        
        let textFieldViewStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(trackerNameTextField)
            stack.addArrangedSubview(exceedLabel)
            return stack
        } ()
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "cancelButtonRedColor")?.cgColor
        cancelButton.setTitleColor(UIColor(named: "cancelButtonRedColor"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.setTitleColor(.white, for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let buttonsStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 8
            stack.addArrangedSubview(cancelButton)
            stack.addArrangedSubview(createButton)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
            return stack
        } ()
        
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalCentering
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        colorsCollection.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(textFieldViewStack)
        contentStackView.addArrangedSubview(tableView)
        contentStackView.addArrangedSubview(emojiCollection)
        contentStackView.addArrangedSubview(colorsCollection)
        contentStackView.addArrangedSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            textFieldViewStack.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            textFieldViewStack.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            textFieldViewStack.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            textFieldViewStack.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            emojiCollection.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 8),
            colorsCollection.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            colorsCollection.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            colorsCollection.heightAnchor.constraint(equalToConstant: 230),
            
            buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 16),
            buttonsStack.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor)
        ])
    }
}

