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
            showAllTrackersForThisDay()
        case "Трекеры на сегодня":
            showAllTrackersForToday()
        case "Завершенные":
            showCompletedTrackersForDay()
            filtersButton.isHidden = false
        case "Незавершенные":
            showIncompleteTrackersForDay()
        default: dismiss(animated: true)
        }
    }
    
    // MARK: - Фильтр "Все трекеры"
    func showAllTrackersForThisDay() {
        viewModel.coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        viewModel.dataUpdated?()
    }
    
    
    // MARK: - Фильтр "Трекеры на сегодня"
    func showAllTrackersForToday() {
        uploadDataFromCoreDataForToday()
        setDateForDatePicker()
        viewModel.dataUpdated?()
    }
    
    func uploadDataFromCoreDataForToday() {
        let calendar = Calendar.current
        let date = Date()
        let dateComponents = calendar.dateComponents([.weekday], from: date)
        let weekDay = dateComponents.weekday
        let weekDayString = viewModel.dayNumberToDayString(weekDayNumber: weekDay)
        print(weekDayString)
        viewModel.coreDataManager.getAllTrackersForWeekday(weekDay: weekDayString)
    }
    
    func setDateForDatePicker() {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: date)
        dateButton.setTitle(dateToString, for: .normal)
        datePicker.date = date
    }
    
    // MARK: - Фильтр "Завершенные"
    func showCompletedTrackersForDay() {
        let completedTrackersID = getCompletedTrackers()
       
        if completedTrackersID.isEmpty {
            print("No completedTrackersID")
            viewModel.coreDataManager.getEmptyBaseForEmptyScreen()
        } else {
            let trackerIDString = completedTrackersID.compactMap { $0 }
            viewModel.coreDataManager.getTrackerWithID(trackerId: trackerIDString)
        }
        viewModel.dataUpdated?()
    }
    
    func getCompletedTrackers() -> [String?] {
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let dateString = dateFormatter.string(from: date)
        let completedTrackersID =
        viewModel.coreDataManager.getAllTrackerRecordForDate(date: dateString)
        print("completedTrackersID \(completedTrackersID)")
        return completedTrackersID
    }
    
    // MARK: - Фильтр "Незавершенные"
    func showIncompleteTrackersForDay() {
        let completedTrackersID = getCompletedTrackers()
        if completedTrackersID.isEmpty {
            viewModel.coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        } else {
            let trackerIDString = completedTrackersID.compactMap { $0 }
            viewModel.coreDataManager.getTrackersExceptWithID(trackerNotToShow: trackerIDString, weekDay: weekDay)
        }
        viewModel.dataUpdated?()
    }
    
    

    
}
