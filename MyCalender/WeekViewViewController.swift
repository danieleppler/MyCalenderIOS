//
//  WeekViewViewController.swift
//  MyCalender
//
//  Landscape-orientation alternative to the month grid: shows a week of
//  days as 7 columns. Each column has its own header (with stacked
//  holiday / all-day banners), and timed events are placed in the column
//  at their hourly position in a shared scrollable 24h grid.
//

import UIKit

final class WeekViewViewController: UIViewController {

    // Data injected from MonthViewController
    var holidays: [Holiday] = []

    // Layout constants
    private let hourHeight: CGFloat = 60
    private var totalHourHeight: CGFloat { hourHeight * 24 }
    private let timeLabelsWidth: CGFloat = 60
    private let dayHeaderHeight: CGFloat = 32
    private let bannerHeight: CGFloat = 18
    private let bannerSpacing: CGFloat = 2
    private let maxBannersPerDay: Int = 3
    private let columnSpacing: CGFloat = 0

    // Computed state
    private var weekDays: [Date] = []
    private var allDayEventsPerDay: [[Event]] = Array(repeating: [], count: 7)
    private var timedEventsPerDay: [[Event]] = Array(repeating: [], count: 7)
    private var holidaysPerDay: [[Holiday]] = Array(repeating: [], count: 7)

    // UI
    private let closeButton = UIButton(type: .system)
    private let headerContainer = UIView()
    private let scrollView = UIScrollView()
    private let gridContentView = UIView()
    private let timeLabelsView = UIView()
    private var dayHeaderViews: [UIView] = []
    private var dayBannerColumns: [UIView] = []
    private var dayGridColumns: [UIView] = []

    private let eventStore = EventStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.applyLocaleAwareDirection()
        buildWeekDays()
        loadData()
        setupChrome()
        setupHeaderContent()
        setupGridContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHeader()
        layoutGrid()
    }

    // MARK: - Setup

    private func buildWeekDays() {
        let calendar = Calendar.current
        let today = Date()
        let start = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private func loadData() {
        let calendar = Calendar.current
        for (index, day) in weekDays.enumerated() {
            // Events
            let events: [Event]
            do {
                events = try eventStore.fetchEvents(forDate: day)
            } catch {
                events = []
            }
            allDayEventsPerDay[index] = events.filter { $0.isAllDay }
            timedEventsPerDay[index] = events.filter { !$0.isAllDay }

            // Holidays — match by date string "YYYY-MM-DD"
            let day0 = calendar.startOfDay(for: day)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let key = formatter.string(from: day0)
            holidaysPerDay[index] = holidays.filter { $0.date == key }
        }
    }

    private func setupChrome() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.buttonSize = .medium
        closeButton.configuration = config
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = .systemBackground
        view.addSubview(headerContainer)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)

        gridContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(gridContentView)

        timeLabelsView.translatesAutoresizingMaskIntoConstraints = false
        gridContentView.addSubview(timeLabelsView)

        let safe = view.safeAreaLayoutGuide
        let totalBannersHeight = CGFloat(maxBannersPerDay) * (bannerHeight + bannerSpacing) + bannerSpacing
        let headerTotalHeight = dayHeaderHeight + totalBannersHeight

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 4),
            closeButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 8),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            headerContainer.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 4),
            headerContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: headerTotalHeight),

            scrollView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),

            gridContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            gridContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            gridContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            gridContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            gridContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            gridContentView.heightAnchor.constraint(equalToConstant: totalHourHeight),
        ])
    }

    private func setupHeaderContent() {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE d"

        for i in 0..<7 {
            // Day header (weekday + date)
            let header = UIView()
            header.backgroundColor = .secondarySystemBackground
            header.layer.borderColor = UIColor.separator.cgColor
            header.layer.borderWidth = 0.5
            headerContainer.addSubview(header)

            let label = UILabel()
            label.text = dayFormatter.string(from: weekDays[i])
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            header.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: header.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            ])
            dayHeaderViews.append(header)

            // Banner column under each day header
            let bannerCol = UIView()
            bannerCol.clipsToBounds = true
            headerContainer.addSubview(bannerCol)
            dayBannerColumns.append(bannerCol)

            // Highlight today
            if calendar.isDateInToday(weekDays[i]) {
                label.textColor = .systemBlue
            }
        }
    }

    private func setupGridContent() {
        // Hour lines + time labels
        for hour in 0...24 {
            let y = CGFloat(hour) * hourHeight
            let line = UIView()
            line.backgroundColor = .separator
            line.frame = CGRect(x: 0, y: y, width: 0, height: 0.5)
            line.tag = 7000 + hour   // tagged so we can resize in layoutGrid
            gridContentView.addSubview(line)

            if hour < 24 && hour > 0 {
                let label = UILabel()
                label.text = String(format: "%02d:00", hour)
                label.font = .systemFont(ofSize: 10)
                label.textColor = .secondaryLabel
                label.textAlignment = .right
                label.frame = CGRect(x: 0, y: y - 8, width: timeLabelsWidth - 6, height: 16)
                timeLabelsView.addSubview(label)
            }
        }

        // Day grid columns
        for _ in 0..<7 {
            let col = UIView()
            col.layer.borderColor = UIColor.separator.cgColor
            col.layer.borderWidth = 0.25
            gridContentView.addSubview(col)
            dayGridColumns.append(col)
        }
    }

    // MARK: - Layout (run on each layout pass)

    private func layoutHeader() {
        let width = headerContainer.bounds.width
        guard width > 0 else { return }

        let columnWidth = (width - timeLabelsWidth) / 7
        for i in 0..<7 {
            let x = timeLabelsWidth + columnWidth * CGFloat(i)
            dayHeaderViews[i].frame = CGRect(x: x, y: 0, width: columnWidth, height: dayHeaderHeight)
            dayBannerColumns[i].frame = CGRect(
                x: x,
                y: dayHeaderHeight,
                width: columnWidth,
                height: headerContainer.bounds.height - dayHeaderHeight
            )
            layoutBanners(in: dayBannerColumns[i], dayIndex: i, columnWidth: columnWidth)
        }
    }

    private func layoutBanners(in container: UIView, dayIndex: Int, columnWidth: CGFloat) {
        container.subviews.forEach { $0.removeFromSuperview() }
        var y: CGFloat = bannerSpacing
        var slotsLeft = maxBannersPerDay

        for holiday in holidaysPerDay[dayIndex] where slotsLeft > 0 {
            let banner = makeBanner(title: holiday.title, color: holiday.uiColor,
                                    x: 2, y: y, width: columnWidth - 4)
            container.addSubview(banner)
            y += bannerHeight + bannerSpacing
            slotsLeft -= 1
        }

        for event in allDayEventsPerDay[dayIndex] where slotsLeft > 0 {
            let color = colorFor(event: event)
            let banner = makeBanner(title: event.eventTitle ?? "", color: color,
                                    x: 2, y: y, width: columnWidth - 4)
            container.addSubview(banner)
            y += bannerHeight + bannerSpacing
            slotsLeft -= 1
        }
    }

    private func layoutGrid() {
        let width = gridContentView.bounds.width
        guard width > 0 else { return }

        timeLabelsView.frame = CGRect(x: 0, y: 0, width: timeLabelsWidth, height: totalHourHeight)

        let columnWidth = (width - timeLabelsWidth) / 7

        // Resize hour lines to span the full grid width
        for hour in 0...24 {
            if let line = gridContentView.viewWithTag(7000 + hour) {
                line.frame = CGRect(x: timeLabelsWidth, y: CGFloat(hour) * hourHeight,
                                    width: width - timeLabelsWidth, height: 0.5)
            }
        }

        // Position day columns and (re)render timed events inside them
        for i in 0..<7 {
            let x = timeLabelsWidth + columnWidth * CGFloat(i)
            dayGridColumns[i].frame = CGRect(x: x, y: 0, width: columnWidth, height: totalHourHeight)
            renderTimedEvents(in: dayGridColumns[i], dayIndex: i, columnWidth: columnWidth)
        }
    }

    private func renderTimedEvents(in column: UIView, dayIndex: Int, columnWidth: CGFloat) {
        // Remove any previous event blocks (not the column border)
        column.subviews.forEach { $0.removeFromSuperview() }

        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: weekDays[dayIndex])
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return }

        for event in timedEventsPerDay[dayIndex] {
            let start = max(event.eventStartDate ?? dayStart, dayStart)
            let end   = min(event.eventEndDate   ?? dayEnd,   dayEnd)

            let yStart = secondsFromMidnight(start, in: calendar) / 60 / 60 * hourHeight
            let yEnd   = secondsFromMidnight(end,   in: calendar) / 60 / 60 * hourHeight
            let height = max(20, yEnd - yStart)

            let block = UIView(frame: CGRect(x: 2, y: yStart, width: columnWidth - 4, height: height))
            block.backgroundColor = colorFor(event: event)
            block.layer.cornerRadius = 3
            block.clipsToBounds = true

            let title = UILabel()
            title.text = event.eventTitle
            title.font = .systemFont(ofSize: 10, weight: .medium)
            title.textColor = .white
            title.numberOfLines = 0
            title.frame = CGRect(x: 4, y: 2, width: block.bounds.width - 8, height: block.bounds.height - 4)
            block.addSubview(title)

            column.addSubview(block)
        }
    }

    private func secondsFromMidnight(_ date: Date, in calendar: Calendar) -> CGFloat {
        let comps = calendar.dateComponents([.hour, .minute, .second], from: date)
        let h = CGFloat(comps.hour ?? 0)
        let m = CGFloat(comps.minute ?? 0)
        let s = CGFloat(comps.second ?? 0)
        return h * 3600 + m * 60 + s
    }

    private func colorFor(event: Event) -> UIColor {
        if let hex = event.eventColor, let color = UIColor(hex: hex) { return color }
        return .systemPurple
    }

    private func makeBanner(title: String, color: UIColor, x: CGFloat, y: CGFloat, width: CGFloat) -> UIView {
        let v = UIView(frame: CGRect(x: x, y: y, width: width, height: bannerHeight))
        v.backgroundColor = color
        v.layer.cornerRadius = 2
        v.clipsToBounds = true

        let label = UILabel(frame: v.bounds.insetBy(dx: 4, dy: 0))
        label.text = title
        label.font = .systemFont(ofSize: 9, weight: .medium)
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        v.addSubview(label)
        return v
    }

    @objc private func closeTapped() {
        dismiss(animated: false)
    }
}
