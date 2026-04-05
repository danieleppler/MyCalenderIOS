//
//  CalenderDay.swift
//  MyCalender
//
//  Created by Ron on 22/03/2026.
//

class CalenderDay {
    let dayNumber: Int
    var events : [Holiday]
    let monthType: MonthType
    let month : Int
    
    
    enum MonthType {
        case current, previous, next
    }
    
    
    init(_ number: Int, type: MonthType = .current, month: Int) {
            self.dayNumber = number
            self.monthType = type
            self.month = month
            events = []
        }
}
