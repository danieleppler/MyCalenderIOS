//
//  UIButton+FAB.swift
//  MyCalender
//

import UIKit

extension UIButton {
    func configureAsFAB(systemImage: String = "plus") {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.image = UIImage(
            systemName: systemImage,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        )
        config.cornerStyle = .fixed
        config.background.cornerRadius = 8
        configuration = config

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.cornerRadius = 8
        layer.masksToBounds = false
    }
}
