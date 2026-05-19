//
//  EventsStore.swift
//  MyCalender
//
//  Created by Ron on 25/03/2026.
//

import UIKit
import Foundation


class HolidaysStore{
    
    private let sessions : URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchEvents(monthToFetch month:Int , yearToFecth year:Int,completion : @escaping (Result<[Holiday],Error>) -> (Void)) {
        let url = HebcalApi.BuildJewishHolidaysURL(monthToFecth: month, yearToFetch: year)
        let request = URLRequest(url: url)
        let task = sessions.dataTask(with: request){
            (data,response,error) in
            let result = self.processEventRequest(data: data, error: error)
            OperationQueue.main.addOperation{
                completion(result)
            }
        }
        task.resume()
    }
    
    
    
    private func processEventRequest(data:Data?,error:Error?) -> Result<[Holiday],Error>{
        guard let jsonData = data else {
            return .failure(error!)
        }
        switch HebcalApi.events(fromJSON: jsonData) {
        case let .success(events):
            return .success(events)
        case let .failure(error):
            return .failure(error)
        }
    }
}
