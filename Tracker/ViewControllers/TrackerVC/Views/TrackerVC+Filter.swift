//
//  TVC+Filter.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import UIKit

extension TrackerViewController: FilterCategoryDelegate {

    var completedTrackersID: [String] {
        getCompletedTrackers()
    }

    func getFilterFromPreviousVC(filter: String) {
        switch filter {
        case SGen.allTrackers: showAllTrackersForThisDay()
        case SGen.todayTrackers: showAllTrackersForToday()
        case SGen.completed: showCompletedTrackersForDay()
        case SGen.incomplete: showIncompleteTrackersForDay()
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
        let date = Date()
        let dateToString = MainHelper.dateToString(date: date)
        dateButton.setTitle(dateToString, for: .normal)
        datePicker.date = date
    }

    // MARK: - Фильтр "Завершенные"
    func showCompletedTrackersForDay() {

        if completedTrackersID.isEmpty {
            viewModel.coreDataManager.getEmptyBaseForEmptyScreen()
        } else {
            viewModel.coreDataManager.getTrackerWithID(trackerId: completedTrackersID)
            viewModel.coreDataManager.getCompletedPinnedTracker(trackerId: completedTrackersID)
        }
        viewModel.dataUpdated?()
    }

    // MARK: - Фильтр "Незавершенные"
    func showIncompleteTrackersForDay() {

        if completedTrackersID.isEmpty {
            viewModel.coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        } else {
            viewModel.coreDataManager.getTrackersExceptWithID(trackerNotToShow: completedTrackersID, weekDay: weekDay)
        }
        viewModel.dataUpdated?()
    }

    // MARK: - Supporting Methods
    func getCompletedTrackers() -> [String] {
        let date = datePicker.date
        let dateString = MainHelper.dateToString(date: date)
        let completedTrackers =
        viewModel.coreDataManager.getAllTrackerRecordForDate(date: dateString)
        let completedTrackersID = completedTrackers.compactMap { $0 }
        print("completedTrackersID \(completedTrackersID)")
        return completedTrackersID
    }
}
