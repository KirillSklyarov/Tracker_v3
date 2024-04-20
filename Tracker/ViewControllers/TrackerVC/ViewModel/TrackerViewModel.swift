//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 09.04.2024.
//

import Foundation

final class TrackerViewModel: TrackerViewModelProtocol  {
    
    let coreDataManager = TrackerCoreManager.shared
    
    var categories = [TrackerCategory]() {
        didSet {
            dataUpdated?()
        }
    }
    
    var filteredData = [TrackerCategory]()
    
    weak var passTrackerToEditDelegate: PassTrackerToEditDelegate?
    
    var isSearchMode = false
    
    var newData: [TrackerCategory] {
        isSearchMode ? filteredData : categories
    }
    
    var dataUpdated: ( () -> Void )?
    
    func updateDataFromCoreData(weekDay: String) {
        coreDataManager.getAllTrackersForWeekday(weekDay: weekDay)
        categories = coreDataManager.fetchData()
    }
    
    func getWeekdayFromCurrentDate(currentDate: Date) -> String {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        return weekDayString
    }
    
    func dayNumberToDayString(weekDayNumber: Int?) -> String {
        let weekDay: [Int:String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                     5: "Чт", 6: "Пт", 7: "Сб"]
        guard let weekDayNumber = weekDayNumber,
              let result = weekDay[weekDayNumber] else { return ""}
        return result
    }
    
    func isTrackerExistInTrackerRecord(indexPath: IndexPath, date: Date) -> (TrackerRecord: TrackerRecord, isExist: Bool) {
        let category = newData[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        let currentDateString = MainHelper.dateToString(date: date)
        let trackerToCheck = TrackerRecord(id: tracker.id, date: currentDateString)
        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)
        
        return (trackerToCheck, check)
    }
    
    func isTrackerExistInTrackerRecordForDatePickerDate(tracker: TrackerCoreData, dateOnDatePicker: Date) -> Bool? {
        guard let trackerId = tracker.id else { return nil}

        let dateOnDatePickerString = MainHelper.dateToString(date: dateOnDatePicker)
        let trackerToCheck = TrackerRecord(id: trackerId, date: dateOnDatePickerString)
        let check = coreDataManager.isTrackerExistInTrackerRecord(trackerToCheck: trackerToCheck)
        return check
    }
}
