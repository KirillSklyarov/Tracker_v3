//
//  ScheduleVC + TableView.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 08.04.2024.
//

import UIKit

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = AppColors.separatorColor
        tableView.tableHeaderView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        let weekDaySwitch = UISwitch()
        weekDaySwitch.backgroundColor = AppColors.switchOff
        weekDaySwitch.layer.cornerRadius = 16
        weekDaySwitch.onTintColor = AppColors.switchOn
        weekDaySwitch.addTarget(self, action: #selector(weekDaySwitchValueChanged), for: .valueChanged)
        cell.accessoryView = weekDaySwitch
        cell.textLabel?.text = viewModel.weekdays[indexPath.row]
        cell.backgroundColor = AppColors.textFieldBackground
        
        if indexPath.row == viewModel.weekdays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.rowHeight
    }
}
