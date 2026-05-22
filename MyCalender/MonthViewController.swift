import UIKit

class MonthViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fab: UIButton!
    @IBOutlet weak var monthsHeaderContainer: UIView!

    let calenderDaysDataSource = CalenderDaysDataSource()

    private var didSetupLayout = false

    private var monthsCollectionView: UICollectionView!
    private var monthList: [(month: Int, year: Int)] = []
    private let visibleMonthsCount: CGFloat = 6

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDayView",
           let dest = segue.destination as? DayViewViewController {
            dest.calendarDay = sender as? CalenderDay
            dest.modalPresentationStyle = .fullScreen
        }
        if segue.identifier == "addEvent" {
            segue.destination.modalPresentationStyle = .fullScreen
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === monthsCollectionView {
            let entry = monthList[indexPath.item]
            switchToMonth(month: entry.month, year: entry.year)
        } else {
            let selectedDay = calenderDaysDataSource.calenderDays[indexPath.row]
            performSegue(withIdentifier: "showDayView", sender: selectedDay)
        }
    }

    @objc func addEventTapped() {
        performSegue(withIdentifier: "addEvent", sender: nil)
    }

    private func switchToMonth(month: Int, year: Int) {
        calenderDaysDataSource.loadMonth(month: month, year: year)
        collectionView.reloadData()
        selectCurrentMonthInHeader(animated: true)
    }

    private func buildMonthList() {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        let monthsBack = 12
        let monthsForward = 12
        var entries: [(month: Int, year: Int)] = []
        for offset in -monthsBack...monthsForward {
            var components = DateComponents()
            components.year = currentYear
            components.month = currentMonth + offset
            components.day = 1
            if let date = calendar.date(from: components) {
                let m = calendar.component(.month, from: date)
                let y = calendar.component(.year, from: date)
                entries.append((month: m, year: y))
            }
        }
        monthList = entries
    }

    private func setupMonthsHeader() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .zero

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(MonthHeaderCell.self, forCellWithReuseIdentifier: MonthHeaderCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self

        monthsHeaderContainer.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: monthsHeaderContainer.topAnchor),
            cv.bottomAnchor.constraint(equalTo: monthsHeaderContainer.bottomAnchor),
            cv.leadingAnchor.constraint(equalTo: monthsHeaderContainer.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: monthsHeaderContainer.trailingAnchor),
        ])
        monthsCollectionView = cv
    }

    private func selectCurrentMonthInHeader(animated: Bool) {
        guard monthsCollectionView != nil else { return }
        let m = calenderDaysDataSource.displayedMonth
        let y = calenderDaysDataSource.displayedYear
        guard let index = monthList.firstIndex(where: { $0.month == m && $0.year == y }) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        monthsCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero
        layout.sectionInset = .zero
        collectionView.collectionViewLayout = layout

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        )
        config.cornerStyle = .fixed
        config.background.cornerRadius = 8
        fab.configuration = config

        fab.layer.shadowColor = UIColor.black.cgColor
        fab.layer.shadowOpacity = 0.3
        fab.layer.shadowOffset = CGSize(width: 0, height: 4)
        fab.layer.shadowRadius = 6
        fab.layer.cornerRadius = 8
        fab.layer.masksToBounds = false

        fab.addTarget(self, action: #selector(addEventTapped), for: .touchUpInside)

        collectionView.delegate = self
        collectionView.dataSource = calenderDaysDataSource

        calenderDaysDataSource.onHolidaysLoaded = { [weak self] in
            self?.collectionView.reloadData()
        }

        buildMonthList()
        setupMonthsHeader()

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.monthsCollectionView.reloadData()
            self.selectCurrentMonthInHeader(animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calenderDaysDataSource.reloadEvents()
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let monthsLayout = monthsCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let totalSpacing = monthsLayout.minimumInteritemSpacing * (visibleMonthsCount - 1)
            let width = floor((monthsCollectionView.bounds.width - totalSpacing) / visibleMonthsCount)
            let height = monthsCollectionView.bounds.height
            let newSize = CGSize(width: max(0, width), height: max(0, height))
            if monthsLayout.itemSize != newSize {
                monthsLayout.itemSize = newSize
                monthsLayout.invalidateLayout()
            }
        }

        guard !didSetupLayout else { return }
        didSetupLayout = true

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = floor(collectionView.bounds.width / 7)
            let height = floor(collectionView.bounds.height / 6)
            layout.itemSize = CGSize(width: width, height: height)
        }

        collectionView.reloadData()
    }
}

extension MonthViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === monthsCollectionView { return monthList.count }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthHeaderCell.reuseIdentifier, for: indexPath) as! MonthHeaderCell
        let entry = monthList[indexPath.item]
        cell.configure(month: entry.month, year: entry.year)
        return cell
    }
}
