//
//  DayCell.swift
//  Mandela
//
//  Created by Ron on 18/03/2026.
//

import UIKit

class DayCell : UICollectionViewCell {
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var eventsStackView: UIStackView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           addBorders()
       }
    
    func configure(with day: CalenderDay) {
           // set day number
           dayLabel.text = "\(day.dayNumber)"
           dayLabel.textColor = day.monthType == .current ? .black : .lightGray
           
           // clear previous banners
           
        if let eventsStackView {
            eventsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
           
           
           // add a banner for each event (max 3 to avoid overflow)
           let eventsToShow = Array(day.events.prefix(3))
        print("trying to add banners to day number \(day.dayNumber)")
           eventsToShow.forEach { event in
               let banner = makeBanner(for: event)
               eventsStackView.addArrangedSubview(banner)
           }
       }
       
       private func makeBanner(for event: Holiday) -> UIView {
           let container = UIView()
           container.layer.cornerRadius = 3
           container.clipsToBounds = true
           
           let isUserAdded = event.userAddedEvent ?? false
           container.backgroundColor = isUserAdded ? .orange: .systemPurple
    
           let label = UILabel()
           label.text = event.hebrew ?? event.title
           label.font = .systemFont(ofSize: 8, weight: .medium)
           label.textColor = .white
           label.textAlignment = .center
           label.adjustsFontSizeToFitWidth = true
           label.minimumScaleFactor = 0.5
           label.translatesAutoresizingMaskIntoConstraints = false
           
           container.addSubview(label)
           NSLayoutConstraint.activate([
               label.topAnchor.constraint(equalTo: container.topAnchor, constant: 1),
               label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -1),
               label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
               label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -2),
               container.heightAnchor.constraint(equalToConstant: 14)
           ])
           
           return container
       }
    
    func addBorders() {
            // right border
            let rightBorder = UIView()
            rightBorder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
            rightBorder.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(rightBorder)
            NSLayoutConstraint.activate([
                rightBorder.topAnchor.constraint(equalTo: contentView.topAnchor),
                rightBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                rightBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                rightBorder.widthAnchor.constraint(equalToConstant: 0.5)
            ])
            
            // bottom border
            let bottomBorder = UIView()
            bottomBorder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(bottomBorder)
            NSLayoutConstraint.activate([
                bottomBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                bottomBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                bottomBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                bottomBorder.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
   
}
