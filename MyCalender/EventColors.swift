//
//  EventColors.swift
//  MyCalender
//

import UIKit

struct EventColor {
    let name: String
    let color: UIColor
}

enum EventColorPresets {
    static let all: [EventColor] = [
        EventColor(name: "Yellow", color: .systemYellow),
        EventColor(name: "Red",    color: .systemRed),
        EventColor(name: "Orange", color: .systemOrange),
        EventColor(name: "Green",  color: .systemGreen),
        EventColor(name: "Blue",   color: .systemBlue),
        EventColor(name: "Purple", color: .systemPurple),
        EventColor(name: "Pink",   color: .systemPink),
    ]
}
