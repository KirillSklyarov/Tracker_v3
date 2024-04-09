//
//  TVC+Filter.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

extension TrackerViewController: FilterCategoryDelegate {
    func getFilterFromPreviousVC(filter: String) {
        switch filter {
        case "Все трекеры":
            viewModel.coreDataManager.setupFetchedResultsController(weekDay: weekDay)
        case "Трекеры на сегодня":
            let calendar = Calendar.current
            let date = Date()
            let dateComponents = calendar.dateComponents([.weekday], from: date)
            let weekDay = dateComponents.weekday
            let weekDayString = viewModel.dayNumberToDayString(weekDayNumber: weekDay)
            print(weekDayString)
            viewModel.coreDataManager.setupFetchedResultsController(weekDay: weekDayString)
            collectionView.reloadData()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yy"
            let dateToString = formatter.string(from: date)
            dateButton.setTitle(dateToString, for: .normal)
            datePicker.date = date
            
        case "Завершенные": dismiss(animated: true)
        default: dismiss(animated: true)
        }
    }
}
