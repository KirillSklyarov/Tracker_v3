//
//  LetterCollectionViewCell.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 13.03.2024.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TrackerCustomCollectionViewCell"
    
    let frameView = UIView()
    let titleLabel = UILabel()
    let emojiLabel = UILabel()
    let plusButton = UIButton()
    let daysLabel = UILabel()
    
    let emojiLabelSize = CGFloat(24)
    let plusButtonSize = CGFloat(34)
    var days = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)

        frameView.layer.masksToBounds = true
        frameView.layer.cornerRadius = 10
        
        plusButton.frame.size.width = plusButtonSize
        plusButton.frame.size.height = plusButtonSize
        plusButton.layer.cornerRadius = plusButton.frame.width / 2
        plusButton.clipsToBounds = true
        
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        plusButton.setImage(plusImage, for: .normal)

        daysLabel.text = "\(days) дней"
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        contentView.addSubViews([frameView, titleLabel, emojiLabel, daysLabel, plusButton])
        
        NSLayoutConstraint.activate([
            frameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            frameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            frameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            frameView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: -12),
            
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: emojiLabelSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: emojiLabelSize),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 16),
            
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 8),
            plusButton.widthAnchor.constraint(equalToConstant: plusButtonSize),
            plusButton.heightAnchor.constraint(equalToConstant: plusButtonSize),
        ])
        
        contentView.backgroundColor = .systemBackground
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
