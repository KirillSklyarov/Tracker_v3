//
//  StatisticViewModel.swift
//  Tracker
//
//  Created by Kirill Sklyarov on 11.04.2024.
//

import Foundation

final class StatisticViewModel: StatisticViewModelProtocol {
    
    // MARK: - Properties
    var titleData = ["Лучший период", "Идеальные дни", "Трекеров завершено", "Среднее значение"]
    
    var bestPeriod: Int? {
        didSet {
            updateData?()
        }
    }
    
    var idealDays = 0 {
        didSet {
            updateData?()
        }
    }
    
    var completedTrackers = 0 {
        didSet {
            updateData?()
        }
    }
    
    var averageNumber = 0.0 {
        didSet {
            updateData?()
        }
    }
    
    var updateData: ( () -> Void )?
    
    var coreDataManager = TrackerCoreManager.shared
    
    // MARK: - Supporting Methods
    func isStatisticsEmpty() -> Bool {
        let isAllNumbersAreZero = bestPeriod == nil &&
        idealDays == 0 &&
        completedTrackers == 0 &&
        averageNumber == 0.0
        
        //        print("bestPeriod \(bestPeriod)")
        //        print("idealDays \(idealDays)")
        //        print("completedTrackers \(completedTrackers)")
        //        print("averageNumber \(averageNumber)")
        //
        //        print("isAllNumbersAreZero \(isAllNumbersAreZero)")
        return isAllNumbersAreZero
    }
    
    func getAllTrackerRecordsIDOLD() -> [String: String] {
        let trackerRecords = coreDataManager.getAllTrackerRecordsIDAndCounts()
        var newDict = [String: String]()
        
        for value in trackerRecords {
            let arrayOfDays = value.value.map( { dateStringToWeekDayString(dateString: $0) })
            let stringOfDays = arrayOfDays.joined(separator: ", ")
            newDict[value.key] = stringOfDays
            
            // Будет вот такой результат trackerRecords ["1B08F418-C184-46B0-A95D-92D39B8FED0A": "Пт, Чт, Ср, Пн, Ср, Сб, Чт, Пн, Вс"]
        }
        return newDict
    }
    
    func deleleAllRecords() {
        coreDataManager.deleteAllRecords()
        coreDataManager.printAllTrackerRecords()
    }
}

// MARK: - Point 1 - Best Period
extension StatisticViewModel {
    func calculateTheBestPeriod() {
        let allTracker = coreDataManager.getAllTrackers()
        
        for tracker in allTracker {
            if tracker.value == "Пн, Вт, Ср, Чт, Пт, Сб, Вс" {
                print("This tracker \(tracker.key) is a OneOff Event - we can calculate")
                calculateTheBestPeriodForOneOffEvent()
            } else {
                print("This tracker is not a OneOff Event")
            }
        }
    }
    
    func calculateTheBestPeriodForOneOffEvent() {
        let trackerRecords = getAllTrackerRecordsID()
        print("trackerRecords \(trackerRecords)")
        let checkTheBestPeriod = isOffOneBestPeriod(trackerRecords: trackerRecords)
        if checkTheBestPeriod.check {
            if checkTheBestPeriod.idealPeriod > (bestPeriod ?? 0) {
                bestPeriod = checkTheBestPeriod.idealPeriod
            }
        }
    }
    
    func isOffOneBestPeriod(trackerRecords: [String: [Date]]) -> (check: Bool, idealPeriod: Int) {
        guard let firstRecord = trackerRecords.first,
              let firstDay = firstRecord.value.first,
              let lastDay = firstRecord.value.last else { return (false, 0)}
        
        let timeInSeconds = lastDay.timeIntervalSince(firstDay)
        let periodBetweenFirstAndLastDay = Int(timeInSeconds / (60 * 60 * 24)) + 1
        let countOfDays = firstRecord.value.count
        
        //        print(firstDay)
        //        print(lastDay)
        //        print(periodBetweenFirstAndLastDay)
        //        print(countOfDays)
        
        if countOfDays == periodBetweenFirstAndLastDay {
            print("We found the ideal period")
            return (true, countOfDays)
        } else {
            print("This tracker doesn't have an ideal period")
            return (false, 0)
        }
    }
    
    func getAllTrackerRecordsID() -> [String: [Date]] {
        let trackerRecords = coreDataManager.getAllTrackerRecordsIDAndCounts()
        var newDict = [String: [Date]]()
        
        for value in trackerRecords {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy"
            let arrayOfDays = value.value.compactMap( { dateFormatter.date(from: $0) }).sorted()
            newDict[value.key] = arrayOfDays
        }
        //
        // Будет вот такой результат trackerRecords ["1B08F418-C184-46B0-A95D-92D39B8FED0A": [2024-03-31 21:00:00 +0000, 2024-04-02 21:00:00 +0000, 2024-04-03 21:00:00 +0000, 2024-04-05 21:00:00 +0000, 2024-04-06 21:00:00 +0000, 2024-04-07 21:00:00 +0000, 2024-04-09 21:00:00 +0000, 2024-04-10 21:00:00 +0000, 2024-04-11 21:00:00 +0000]]
        
        return newDict
    }
}

// MARK: - Point 2 - Ideal Days
extension StatisticViewModel {
    func calculationOfIdealDays() {
        let trackersToComplete = getCountOfTrackersToCompleteForAllDays()
        let trackerRecordsDict = getTrackerRecordsDictFromCoreData()
        
        let commonElementsOfDicts = trackerRecordsDict.filter { (key, value) in
            trackersToComplete[key] == value
        }.count
        
        idealDays = commonElementsOfDicts
    }
    
    func getCountOfTrackersToCompleteForAllDays() -> [String: Int] {
        var newDict = [String:Int]()
        
        let weekDay = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        
        for day in weekDay {
            let trackerToCompleteThisDay = coreDataManager.getAllTrackersForTheDay(weekDay: day)
            guard let trackerToAdd = trackerToCompleteThisDay.first else { return [:]}
            newDict[trackerToAdd.key] = trackerToAdd.value
        }
        return newDict
    }
    
    func getTrackerRecordsDictFromCoreData() -> [String:Int] {
        let dict = coreDataManager.getAllTrackerRecordsDaysAndCounts()
        var testDict = [String:Int]()
        
        for element in dict {
            let key = dateStringToWeekDayString(dateString: element.key)
            testDict[key] = element.value
        }
        return testDict
    }
    
    func dateStringToWeekDayString(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        guard let date = dateFormatter.date(from: dateString) else { return "999"}
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        let weekDay: [Int:String] = [1: "Вс", 2: "Пн", 3: "Вт", 4: "Ср",
                                     5: "Чт", 6: "Пт", 7: "Сб"]
        guard let result = weekDay[dayOfWeek] else { return "888"}
        return result
    }
}

// MARK: - Point 3 - Completed Trackers
extension StatisticViewModel {
    func countOfCompletedTrackers() {
        let result = coreDataManager.countOfAllCompletedTrackers()
        completedTrackers = result
        //        print("completedTrackers \(String(completedTrackers ?? 999))")
    }
}
   
// MARK: - Point 4 - Completed Trackers Per Day
extension StatisticViewModel {
    func trackerRecordsPerDay() {
        let arrayOfDates = coreDataManager.getAllTrackerRecordDates()
        print("trackerRecords \(arrayOfDates)")
        let cleanArray = arrayOfDates.compactMap { $0 }
        let recordsCount = arrayOfDates.count
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let arrayOfRealDates = cleanArray.compactMap { formatter.date(from: $0) }
        
        guard let firstDate = arrayOfRealDates.sorted(by: { $0 < $1 }).first,
              let lastDate = arrayOfRealDates.sorted(by: { $0 < $1 }).last else { return }
        
        let timeInt = lastDate.timeIntervalSince(firstDate)
        let days = timeInt / (60 * 60 * 24) + 1
        let recordsPerDay = Double(recordsCount) / days
        let recordsPerDayFormat = String(format: "%.2f", recordsPerDay)
        if let result = Double(recordsPerDayFormat) {
            averageNumber = result
        }
        
        //        coreDataManager.printAllTrackerRecords()
        
        //        print("firstDate \(firstDate)")
        //        print("lastDate \(lastDate)")
        //        print("days \(days)")
        //        print("recordsCount \(recordsCount)")
        
    }
}
