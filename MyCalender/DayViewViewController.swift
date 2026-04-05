//
//  DayViewViewController.swift
//  MyCalender
//
//  Created by Ron on 29/03/2026.
//

import UIKit

class DayViewViewController : UIViewController{
       
    @IBOutlet weak var allDayView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!       // the tall 1440pt view
    @IBOutlet weak var timeLabelsView: UIView!
    @IBOutlet weak var eventsCanvasView: UIView!
    @IBOutlet weak var fixedHolidaysCanvasView : UIView!
    @IBOutlet weak var circleDayLabel:UIView!
    @IBOutlet weak var dayLabel:UILabel!
    @IBOutlet weak var addEventButton : UIButton!
    
    weak var currentTimeDot: UIView?
     weak var currentTimeLine: UIView?
    
    var calendarDay: CalenderDay?  // received from segue
    var todayEvents: [Holiday] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAddEventButton()
        drawHourLines()
        drawTimeLabels()
        configureTopDayView()
        loadEvents()
        renderEvents()
    }
    
    func configureAddEventButton(){
        addEventButton.layer.shadowColor = UIColor.black.cgColor
        addEventButton.layer.shadowOpacity = 0.3
        addEventButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addEventButton.layer.shadowRadius = 4
        addEventButton.setTitleColor(.white, for: .normal)
        addEventButton.backgroundColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1) // #4185F4
    }
    
   
    
    
    func configureTopDayView(){
        circleDayLabel.layer.cornerRadius = circleDayLabel.frame.height / 2
        circleDayLabel.clipsToBounds = true
        circleDayLabel.backgroundColor = .systemBlue // or whatever color
        if let label = circleDayLabel.viewWithTag(1) as? UILabel {
            label.text = String(calendarDay?.dayNumber ?? 0)
        }
        dayLabel.text = "Sunday"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let hourHeight: CGFloat = 60 // height per hour slot
        let totalHeight = hourHeight * 24 // 1440pt total
        let hoursWidth: CGFloat = 104
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: totalHeight)
        timeLabelsView.frame = CGRect(x: 0, y: 0, width: hoursWidth, height: totalHeight)
        eventsCanvasView.frame = CGRect(x: hoursWidth + 8, y: 0, width: scrollView.frame.width - hoursWidth - 8, height: totalHeight)
        fixedHolidaysCanvasView.frame = CGRect(x: hoursWidth + 8, y: 0, width: scrollView.frame.width - hoursWidth - 8, height: totalHeight)
        
        scrollToCurrentHour()
    }
    
    
    func loadEvents() {
        guard let calendarDay = calendarDay else { return }
        todayEvents = calendarDay.events
    }
    
    func addCurrentTimeLine() {
        let now = Date()
        let calendar = Calendar.current
        let hours = CGFloat(calendar.component(.hour, from: now))
        let minutes = CGFloat(calendar.component(.minute, from: now))
        let y = (hours + minutes / 60) * 60

        // red dot
        let dot = UIView()
        dot.backgroundColor = .systemRed
        dot.frame = CGRect(x: -4, y: y - 4, width: 8, height: 8)
        dot.layer.cornerRadius = 4
        eventsCanvasView.addSubview(dot)

        // red line
        let line = UIView()
        line.backgroundColor = .systemRed
        line.frame = CGRect(x: 0, y: y, width: eventsCanvasView.bounds.width, height: 2)
        eventsCanvasView.addSubview(line)

        // store references so we can update them
        currentTimeDot = dot
        currentTimeLine = line

        // update every minute
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateCurrentTimeLine()
        }
    }

    func updateCurrentTimeLine() {
        let now = Date()
        let calendar = Calendar.current
        let hours = CGFloat(calendar.component(.hour, from: now))
        let minutes = CGFloat(calendar.component(.minute, from: now))
        let y = (hours + minutes / 60) * 60

        currentTimeDot?.frame = CGRect(x: -4, y: y - 4, width: 8, height: 8)
        currentTimeLine?.frame = CGRect(x: 0, y: y, width: eventsCanvasView.bounds.width, height: 2)
    }

   
    func scrollToCurrentHour() {
        let hour = Calendar.current.component(.hour, from: Date())
        let y = CGFloat(max(0, hour - 1)) * 60
        scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: false)
    }
    
    func drawHourLines() {
        for hour in 0..<24 {
            let y = CGFloat(hour) * 60

            // full hour line
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = true
            line.backgroundColor = UIColor.separator
            line.frame = CGRect(x: 0, y: y, width: eventsCanvasView.bounds.width, height: 0.5)
            eventsCanvasView.addSubview(line)
        }
    }

    func drawTimeLabels() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"   // "9 AM"

        for hour in 1..<24 {
            let y = CGFloat(hour) * 60
            let label = UILabel()
            label.text = "\(hour < 12 ? hour : hour == 12 ? 12 : hour - 12) \(hour < 12 ? "AM" : "PM")"
            label.font = .systemFont(ofSize: 10)
            label.textColor = .secondaryLabel
            label.textAlignment = .right
            label.frame = CGRect(x: 0, y: y - 8, width: 44, height: 16)
            timeLabelsView.addSubview(label)
        }
    }
    
    func renderEvents() {
        for event in todayEvents {
            let block = makeEventBlock(event)
            event.userAddedEvent ?? false ? fixedHolidaysCanvasView.addSubview(block) : eventsCanvasView.addSubview(block)
        }
    }

    func makeEventBlock(_ event: Holiday) -> UIView {
        let y      = CGFloat(Float(event.date) ?? 0) * 60 + 2
        let height = CGFloat(Float(event.date) ?? 0) * 60 - 4
        let width  = eventsCanvasView.bounds.width - 8

        let view = UIView()
        view.frame = CGRect(x: 4, y: y, width: width, height: height)
        view.backgroundColor = .purple
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true

        // left color bar
        let bar = UIView()
        bar.backgroundColor = event.userAddedEvent ?? false ? .green : .orange
         
        bar.frame = CGRect(x: 0, y: 0, width: 3, height: height)
        view.addSubview(bar)

        // title label
        let title = UILabel()
        title.text = event.title
        title.font = .systemFont(ofSize: 12, weight: .medium)
        title.textColor = .white
        title.frame = CGRect(x: 10, y: 4, width: width - 14, height: 16)
        view.addSubview(title)

        // time label
        let time = UILabel()
        time.text = event.date
        time.font = .systemFont(ofSize: 11)
        time.textColor = .white.withAlphaComponent(0.85)
        time.frame = CGRect(x: 10, y: 20, width: width - 14, height: 14)
        view.addSubview(time)

//        // tap gesture
//        let tap = UITapGestureRecognizer(target: self, action: #selector(eventTapped(_:)))
//        view.addGestureRecognizer(tap)
//        view.tag = event.id   // store event id on the view

        return view
    }
    
}


