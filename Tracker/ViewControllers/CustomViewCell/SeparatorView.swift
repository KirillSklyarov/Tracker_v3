//
//  SeparatorView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 30.03.2024.
//

import UIKit

final class ContextMenuSeparator: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
