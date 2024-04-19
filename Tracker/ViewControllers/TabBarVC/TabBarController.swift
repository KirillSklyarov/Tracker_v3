//
//  TabBarController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 12.03.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarController()
        
    }
    
    func setupTabBarController() {
        let trackerViewModel = TrackerViewModel()
        let trackerVC = setupNavigationController(controller: TrackerViewController(viewModel: trackerViewModel), title: "Trackers".localized())
        
        let statisticsViewModel = StatisticViewModel()
        let statisticVC = setupNavigationController(controller: StatisticViewController(viewModel: statisticsViewModel), title: "Statistics".localized())
        
        trackerVC.tabBarItem = UITabBarItem(title: "Trackers".localized(), image: UIImage(systemName: "record.circle.fill"), tag: 0)
        statisticVC.tabBarItem = UITabBarItem(title: "Statistics".localized(), image: UIImage(systemName: "hare.fill"), tag: 1)
        
        self.viewControllers = [trackerVC, statisticVC]
        
        self.tabBar.backgroundColor = .white
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor(named: "tabBarBorderColor")?.cgColor
    }
    
    private func setupNavigationController(controller: UIViewController, title: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.topItem?.title = title
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.backgroundColor = .systemBackground
        navigationController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationItem.hidesSearchBarWhenScrolling = false
        return navigationController
    }
}
