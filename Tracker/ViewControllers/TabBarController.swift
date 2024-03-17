//
//  TabBarController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 12.03.2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarController()
        
    }
    
    func setupTabBarController() {
        
        let trackerVC = setupNavigationController(controller: TrackerViewController(), title: "Трекеры")
        let statisticVC = setupNavigationController(controller: StatisticViewController(), title: "Статистика")
        
        trackerVC.tabBarItem = UITabBarItem(title: "Трекер", image: UIImage(systemName: "record.circle.fill"), tag: 0)
        statisticVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)

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
        return navigationController
    }

}
