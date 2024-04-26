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
        getPinnedTrackersForToday()
        getTrackersForWeekDay(weekDay: weekDay)
        viewModel.dataUpdated?()
    }

    func getPinnedTrackersForToday() {
        viewModel.coreDataManager.setupPinnedFRC()
    }

    func getTrackersForWeekDay(weekDay: String) {
        viewModel.coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
    }

    // MARK: - Фильтр "Трекеры на сегодня"
    func showAllTrackersForToday() {
        getPinnedTrackersForToday()
        getTrackersForToday()
        setDateForDatePicker()
        viewModel.dataUpdated?()
    }

    func getTrackersForToday() {
        let todayWeekDayString = getTodayWeekday()
        viewModel.coreDataManager.getAllTrackersForWeekday(weekDay: todayWeekDayString)
    }

    func getTodayWeekday() -> String {
        let calendar = Calendar.current
        let date = Date()
        let dateComponents = calendar.dateComponents([.weekday], from: date)
        let weekDay = dateComponents.weekday
        let weekDayString = viewModel.dayNumberToDayString(weekDayNumber: weekDay)
        print(weekDayString)
        return weekDayString
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
            viewModel.coreDataManager.getCompletedPinnedTracker(trackerId: completedTrackersID)
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
            getPinnedTrackersForToday()
        } else {
            viewModel.coreDataManager.getTrackersExceptWithID(trackerNotToShow: completedTrackersID, weekDay: weekDay)
            viewModel.coreDataManager.getInCompletePinnedTracker(trackerNotToShow: completedTrackersID)
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
