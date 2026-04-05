//
//  CalenderDaysDataSource.swift
//  MyCalender
//
//  Created by Ron on 22/03/2026.
//

import UIKit

class CalenderDaysDataSource: NSObject, UICollectionViewDataSource {
    
    var calenderDays = [CalenderDay]()
    private let store = EventStore()
    
    override init() {
        super.init()
        let month = Calendar.current.component(.month, from: Date())
        calenderDays = buildCalendarDays(year: 2026, month: month)
        store.fetchEvents(monthToFetch: month,yearToFecth: 2026){(eventResult) in
            switch eventResult {
            case let .success(events):
                print("Successfully found \(events.count) events.")
                self.AssignEventsToCalenderDays(eventsToAdd: events)
            case let .failure(error): print("Error fetching events: \(error)")
            }
        }
        
    }
    
    func AssignEventsToCalenderDays(eventsToAdd : [Holiday]){
        for event in eventsToAdd{
            let currentDay = calenderDays.first(where: { $0.dayNumber == Int(event.date.split(separator: "-")[2])})
            currentDay?.events.append(event)
            print("added event \(event.title) to day number \(currentDay?.dayNumber)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
        cell.configure(with: calenderDays[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calenderDays.count
    }
    
    func buildCalendarDays(year: Int, month: Int) -> [CalenderDay] {
        
        var firstWeekday = firstDayOfMonth(year: year, month: month)
        if firstWeekday == 0 {
                firstWeekday = 7
            }
        
        // days in current month
        let currentMonthDays = daysInMonth(year: year, month: month)
        
        // days in previous month
        let prevMonthDays = daysInMonth(year: year, month: month - 1)
        
        var days: [CalenderDay] = []
        
        // fill leading days from previous month
        for i in (0..<firstWeekday).reversed() {
            days.append(CalenderDay(prevMonthDays - i, type: .previous,month: month))
        }
        
        // fill current month
        for i in 1...currentMonthDays {
            days.append(CalenderDay(i, type: .current,month: month))
        }
        
        // fill trailing days from next month
        let remaining = 42 - days.count
        for i in 1...remaining {
            days.append(CalenderDay(i, type: .next,month: month))
        }
        
        return days // always exactly 42
    }

    func daysInMonth(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        let date = Calendar.current.date(from: components)!
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }

    func firstDayOfMonth(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let date = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: date) - 1 // 0=Sun
    }
}
