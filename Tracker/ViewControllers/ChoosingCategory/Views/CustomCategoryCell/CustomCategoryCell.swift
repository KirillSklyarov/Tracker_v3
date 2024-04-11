//
//  CustomCategoryCell.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 07.04.2024.
//

import UIKit

final class CustomCategoryCell: UITableViewCell {
    
    static let identifier = "CustomCategoryCell"
    
    let titleLabel = UILabel()
    var checkmarkImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellDesign()
        
    }
    
    func setupCellDesign() {
        
        self.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        
        checkmarkImage.isHidden = true
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        let image = UIImage(named: "bluecheckmark")
        checkmarkImage.image = image
        checkmarkImage.contentMode = .center
        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(checkmarkImage)
        
        contentView.addSubViews([stack])
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.heightAnchor.constraint(equalToConstant: 24),
            
            checkmarkImage.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    func configureCell(viewModelCategories: String) {
        titleLabel.text = viewModelCategories
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
