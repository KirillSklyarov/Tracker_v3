//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 14.03.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private let tableView = UITableView()
    private lazy var doneButton = setupButtons(title: "Готово")

    private let weekdays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    private let rowHeight = CGFloat(75)
    private lazy var tableViewHeight = CGFloat(weekdays.count) * rowHeight

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupTableView()

    }
    
    private func setupUI() {
        
        self.title = "Расписание"
        view.backgroundColor = UIColor(named: "projectBackground")

        
        view.addSubViews([tableView, doneButton])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.cornerRadius = 10
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
    }
    
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }
    
    @objc private func weekDayswitchValueChanded(_ sender: UISwitch) {
        
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        let weekDayswitch = UISwitch()
        weekDayswitch.addTarget(self, action: #selector(weekDayswitchValueChanded), for: .valueChanged)
        cell.accessoryView = weekDayswitch
        
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
}

//MARK: - SwiftUI
import SwiftUI
struct ProviderSchedule : PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            return ScheduleViewController()
        }
        
        typealias UIViewControllerType = UIViewController
        
        
        let viewController = ScheduleViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<ProviderSchedule.ContainterView>) -> ScheduleViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: ProviderSchedule.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<ProviderSchedule.ContainterView>) {
            
        }
    }
}
