//
//  TrackerViewModelProtocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

protocol TrackerViewModelProtocol {
    func getWeekdayFromCurrentDate(currentDate: Date) -> String
    func dateToString(date: Date) -> String
    func updateDataFromCoreData(weekDay: String)
    func isTrackerExistInTrackerRecord(indexPath: IndexPath, date: Date) -> (TrackerRecord: TrackerRecord, isExist: Bool)
    func isTrackerExistInTrackerRecordForDatePickerDate(tracker: TrackerCoreData, dateOnDatePicker: Date) -> Bool? 
    func daysLetters(count: Int) -> String
    func dayNumberToDayString(weekDayNumber: Int?) -> String
//    func countOfDaysForTheTrackerInString(tracker: TrackerRecord) -> String
    func countOfDaysForTheTrackerInString(trackerId: String) -> String
    
    var coreDataManager: TrackerCoreManager { get }
    var dataUpdated: ( () -> Void )? { get set }
    var isSearchMode: Bool { get set }
    var categories: [TrackerCategory] { get set }
    var filteredData: [TrackerCategory] { get set }
    var passTrackerToEditDelegate: PassTrackerToEditDelegate? { get set }
}