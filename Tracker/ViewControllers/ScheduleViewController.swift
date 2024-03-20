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
    private var arrayOfIndexes = [Int]()
    
    var scheduleToPass: ( (String) -> Void )?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupTableView()

    }
    
    private func setupUI() {
        
        let tableViewHeight = CGFloat(weekdays.count) * rowHeight
        
        self.title = "Расписание"
        view.backgroundColor = UIColor(named: "projectBackground")

        view.addSubViews([tableView, doneButton])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
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
        button.addTarget(self, action: #selector(scheduleDoneButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc private func weekDayswitchValueChanded(_ sender: UISwitch) {
        guard let cell = sender.superview as? UITableViewCell,
        let indexPath = tableView.indexPath(for: cell) else { return }
        if sender.isOn {
            arrayOfIndexes.append(indexPath.row)
        } else {
            arrayOfIndexes.remove(at: indexPath.row)
        }
    }
    
    func getStringFromArray(array: [Int]) -> String {
        if array.count == 7 { return "Каждый день"} else {
            let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            let arrayOfStrings = array.map { daysOfWeek[$0] }
            let resultString = arrayOfStrings.joined(separator: ", ")
            return resultString
        }
    }
    
    @objc private func scheduleDoneButtonTapped(_ sender: UIButton) {
        let scheduleString = getStringFromArray(array: arrayOfIndexes)
        scheduleToPass?(scheduleString)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        let weekDayswitch = UISwitch()
        weekDayswitch.onTintColor = UIColor(named: "switchOnColor")
        weekDayswitch.addTarget(self, action: #selector(weekDayswitchValueChanded), for: .valueChanged)
        cell.accessoryView = weekDayswitch
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.backgroundColor = UIColor(named: "textFieldBackgroundColor")
        
        if indexPath.row == weekdays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
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
