//
//  EventDetailsViewController.swift
//  MyCalender
//
//  Created by Ron on 28/03/2026.
//

import UIKit

class EventDetailsViewController : UIViewController{
    
    var currEvent : Holiday?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let event = currEvent else { return }
        pupolateFields()
    }
    
    func pupolateFields(){
        
    }
    
}
