//
//  Cre+ScrollView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

// MARK: - setupScrollView
extension CreatingNewTrackerViewController {
    
    func setupScrollView() {
        
        let screenScrollView = UIScrollView()
        
        view.addSubViews([screenScrollView])
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let contentView = UIView()
        
        screenScrollView.addSubViews([contentView])
        
//        let hConst = contentView.heightAnchor.constraint(equalTo: screenScrollView.heightAnchor)
//        hConst.isActive = true
//        hConst.priority = UILayoutPriority(50)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor),
        ])
        
        contentView.addSubViews([contentStackView])
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    func setupContentStack() {
                
        var tableViewHeight: CGFloat {
            rowHeight * CGFloat(viewModel.tableViewRows.count)
        }
        
        let textFieldViewStack = UIStackView()
        textFieldViewStack.axis = .vertical
        textFieldViewStack.spacing = 8
        [trackerNameTextField, exceedLabel].forEach { textFieldViewStack.addArrangedSubview($0) }
        
        let buttonsStack = setupButtonsStack()
        
        [textFieldViewStack, contentStackView, tableView, emojiCollection, colorsCollection, buttonsStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false}
        
        [textFieldViewStack, tableView, emojiCollection, colorsCollection, buttonsStack].forEach { contentStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            
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
        cancelButton.layer.borderColor = AppColors.buttonRed?.cgColor
        cancelButton.setTitleColor(AppColors.buttonRed, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.setTitleColor(AppColors.buttonTextColor, for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(createButton)
        return stack
    }
}
