//
//  BaseViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 10.04.2024.
//

import UIKit

// Мы сделали BaseViewController чтобы не создавать каждый раз инициализатор в каждом вью
class BaseViewController: UIViewController {

    var viewModel: ViewModelProtocol

    init(viewModel: ViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
