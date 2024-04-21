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
    let emojiView = UIView()
    let emojiLabel = UILabel()
    let plusButton = UIButton()
    let daysLabel = UILabel()
    let pinImage = UIImageView()
    
    let emojiViewSize = CGFloat(24)
    let plusButtonSize = CGFloat(34)
    let titleLabelHeight = CGFloat(34)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = AppColors.background
        
        frameView.layer.cornerRadius = 16
        
        emojiView.frame.size.width = emojiViewSize
        emojiView.frame.size.height = emojiViewSize
        emojiView.layer.cornerRadius = emojiView.frame.width / 2
        
        emojiLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emojiLabel.textAlignment = .center
        
        emojiView.backgroundColor = AppColors.trackerCellEmojiRound 
        
        emojiView.addSubViews([emojiLabel])
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
        ])
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = AppColors.trackerCellTitleLabel
        
        let pin = UIImage(named: "pin")
        pinImage.image = pin
        pinImage.isHidden = true
        
        frameView.addSubViews([titleLabel, emojiView, pinImage])
        
        plusButton.frame.size.width = plusButtonSize
        plusButton.frame.size.height = plusButtonSize
        plusButton.layer.cornerRadius = plusButton.frame.width / 2
        plusButton.clipsToBounds = true
        
        guard let color = AppColors.plusButton else { return }
        
        let plusImage = UIImage(systemName: "plus")?.withTintColor(color, renderingMode: .alwaysOriginal)
        plusButton.setImage(plusImage, for: .normal)
        
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        contentView.addSubViews([frameView, daysLabel, plusButton])
        
        NSLayoutConstraint.activate([
            frameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            frameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            frameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            frameView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: frameView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight),
            
            emojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: emojiViewSize),
            emojiView.heightAnchor.constraint(equalToConstant: emojiViewSize),
            
            pinImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            pinImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 16),
            
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 8),
            plusButton.widthAnchor.constraint(equalToConstant: plusButtonSize),
            plusButton.heightAnchor.constraint(equalToConstant: plusButtonSize),
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
