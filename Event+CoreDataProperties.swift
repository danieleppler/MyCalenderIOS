//
//  Event+CoreDataProperties.swift
//  MyCalender
//
//  Created by Ron on 05/04/2026.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var eventId: Int32
    @NSManaged public var eventTitle: String?
    @NSManaged public var eventStartDate: Date?
    @NSManaged public var eventEndDate: Date?

}

extension Event : Identifiable {

}
