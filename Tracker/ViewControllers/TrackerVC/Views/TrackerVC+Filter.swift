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
        viewModel.isFilter = true
        viewModel.filter = filter
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
        blueFilterButtonBackgroundColor()
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
        changeFilterButtonBackgroundColor()
        viewModel.dataUpdated?()
    }

    func getTrackersForToday() {
        let todayWeekDayString = getTodayWeekday()
        getTrackersForWeekDay(weekDay: todayWeekDayString)
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
            showEmptyCollections()
        } else {
            getCompletedPinnedTrackers(completedTrackers: completedTrackersID)
            getCompletedTrackers(completedTrackers: completedTrackersID)
        }
        viewModel.dataUpdated?()
        changeFilterButtonBackgroundColor()
    }

    func showEmptyCollections() {
        viewModel.coreDataManager.getEmptyPinnedCollection()
        viewModel.coreDataManager.getEmptyTrackerCollection()
    }

    func getCompletedPinnedTrackers(completedTrackers: [String]) {
        viewModel.coreDataManager.getCompletedPinnedTracker(trackerId: completedTrackers)
    }

    func getCompletedTrackers(completedTrackers: [String]) {
        viewModel.coreDataManager.getCompletedTrackersWithID(completedTrackerId: completedTrackers)
    }

    // MARK: - Фильтр "Незавершенные"
    func showIncompleteTrackersForDay() {

        if completedTrackersID.isEmpty {
            getPinnedTrackersForToday()
            getTrackersForWeekDay(weekDay: weekDay)
        } else {
            getIncompletePinnedTrackers(trackerNotToShow: completedTrackersID)
            getIncompleteTrackers(trackerNotToShow: completedTrackersID)
        }
        viewModel.dataUpdated?()
        changeFilterButtonBackgroundColor()
    }

    func getIncompletePinnedTrackers(trackerNotToShow: [String]) {
        viewModel.coreDataManager.getInCompletePinnedTracker(trackerNotToShow: trackerNotToShow)
    }

    func getIncompleteTrackers(trackerNotToShow: [String]) {
        viewModel.coreDataManager.getTrackersExceptWithID(trackerNotToShow: completedTrackersID, weekDay: weekDay)
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

    func changeFilterButtonBackgroundColor() {
        filtersButton.backgroundColor = AppColors.buttonRed
    }

    func blueFilterButtonBackgroundColor() {
        filtersButton.backgroundColor = AppColors.filterButton
    }
}
