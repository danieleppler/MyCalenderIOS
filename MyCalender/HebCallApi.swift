//
//  HebCallApi.swift
//  MyCalender
//
//  Created by Ron on 25/03/2026.
//

import Foundation

enum EndPoint: String {
    case jewishHolidays = "jewishHolidays"
}

struct HebcalApi {
    private static let baseURLString = "https://www.hebcal.com/hebcal"
    
    static func BuildJewishHolidaysURL(monthToFecth month: Int,yearToFetch year:Int) -> URL {
        var components = URLComponents(string: baseURLString)!
        components.queryItems = [
            URLQueryItem(name: "v", value: "1"),
            URLQueryItem(name: "cfg", value: "json"),
            URLQueryItem(name: "maj", value: "on"),
            URLQueryItem(name: "min", value: "on"),
            URLQueryItem(name: "mod", value: "on"),
            URLQueryItem(name: "nx", value: "on"),
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "month", value: String(month)),
            URLQueryItem(name: "ss", value: "on"),
            URLQueryItem(name: "mf", value: "on"),
            URLQueryItem(name: "c", value: "off"),
            URLQueryItem(name: "M", value: "on"),
            URLQueryItem(name: "s", value: "on")
        ]
        return components.url!
    }
    
    static func events(fromJSON data: Data) -> Result<[Holiday], Error> {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(HebcalResponse.self, from: data)
            return .success(response.items)
        } catch {
            // ✅ print exact decode error
            print("Decode error: \(error)")
            return .failure(error)
        }
    }
}

// ✅ Correct structure — Hebcal returns { "items": [...] }
struct HebcalResponse: Codable {
    let items: [Holiday]
}
