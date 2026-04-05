//
//  Event.swift
//  MyCalender
//
//  Created by Ron on 22/03/2026.
//

import UIKit

struct Holiday: Codable {
    let title: String
    let date: String      // "2026-03-25"
    let category: String
    let hebrew: String?
    let userAddedEvent : Bool?
    
    enum CodingKeys: String, CodingKey {
        case title
        case date
        case category
        case hebrew
        case userAddedEvent
    }
}
