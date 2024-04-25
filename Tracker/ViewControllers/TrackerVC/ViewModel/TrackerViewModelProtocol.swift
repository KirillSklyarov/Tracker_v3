//
//  TrackerViewModelProtocol.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

protocol TrackerViewModelProtocol {
    func getWeekdayFromCurrentDate(currentDate: Date) -> String
    func updateDataFromCoreData(weekDay: String)

    func isTrackerExistInTrackerRecord(tracker: TrackerCoreData, date: Date) ->
    (TrackerRecord: TrackerRecord, isExist: Bool)?

    func isTrackerExistInTrackerRecordForDatePickerDate(tracker: Tracker, dateOnDatePicker: Date) -> Bool?
    func dayNumberToDayString(weekDayNumber: Int?) -> String

    var coreDataManager: TrackerCoreManager { get }
    var dataUpdated: ( () -> Void )? { get set }
    var isSearchMode: Bool { get set }
    var categories: [TrackerCategory] { get set }
    var filteredData: [TrackerCategory] { get set }
    var passTrackerToEditDelegate: PassTrackerToEditDelegate? { get set }

}
