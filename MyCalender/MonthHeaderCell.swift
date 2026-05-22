//
//  MonthHeaderCell.swift
//  MyCalender
//

import UIKit

class MonthHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "MonthHeaderCell"

    private let monthLabel = UILabel()
    private let yearLabel = UILabel()

    override var isSelected: Bool {
        didSet { updateSelection() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        updateSelection()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        updateSelection()
    }

    private func setupLayout() {
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.clipsToBounds = true

        monthLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        monthLabel.textAlignment = .center
        monthLabel.translatesAutoresizingMaskIntoConstraints = false

        yearLabel.font = .systemFont(ofSize: 10, weight: .regular)
        yearLabel.textColor = .secondaryLabel
        yearLabel.textAlignment = .center
        yearLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(monthLabel)
        contentView.addSubview(yearLabel)

        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -6),
            yearLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            yearLabel.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 2),
        ])
    }

    func configure(month: Int, year: Int) {
        let formatter = DateFormatter()
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            formatter.dateFormat = "MMM"
            monthLabel.text = formatter.string(from: date)
        } else {
            monthLabel.text = "—"
        }
        yearLabel.text = "\(year)"
    }

    private func updateSelection() {
        if isSelected {
            contentView.backgroundColor = .systemBlue
            monthLabel.textColor = .white
            yearLabel.textColor = UIColor.white.withAlphaComponent(0.85)
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            contentView.backgroundColor = .secondarySystemBackground
            monthLabel.textColor = .label
            yearLabel.textColor = .secondaryLabel
            contentView.layer.borderColor = UIColor.separator.cgColor
        }
    }
}
