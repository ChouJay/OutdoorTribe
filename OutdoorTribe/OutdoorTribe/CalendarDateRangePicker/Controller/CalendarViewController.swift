//
//  CalendarViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/15.
//

import Foundation
import UIKit

// swiftlint:disable cyclomatic_complexity

protocol PassDateRangeToDetailVCDelegate {
    func passDateRangeToDetailVC(dateRange: [Date])
}

protocol PassDateRangeToPostVCDelegate {
    func passDateRange(dateRange: [Date])
}

class CalendarPickerViewController: UIViewController {
    
    let dateFormatter2: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
        return dateFormatter
    }()
    
    var dateStringArray = [String]()
    
    var rentAvailableDate: [Date]? {
        didSet {
            dateStringArray = []
            guard let rentAvailableDate = rentAvailableDate else { return }
            for date in rentAvailableDate {
                let dateString = dateFormatter2.string(from: date)
                print(dateString)
                dateStringArray.append(dateString)
            }
        }
    }
    
    var passDateToDetailVCDelegate: PassDateRangeToDetailVCDelegate?
    var passDateDelegate: PassDateRangeToPostVCDelegate?
    var selectedIndexPath = IndexPath(item: 0, section: 0)
    var selectedDates = [Date]()
    var selectedCount = 0 {
        didSet {
            if selectedCount == 2 {
                footerView.confirmButton.isEnabled = true
                footerView.confirmButton.alpha = 1
            }
        }
    }
    
  // MARK: Views
    var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()

    var dateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.autoresizesSubviews = false

        return collectionView
    }()

    lazy var headerView = CalendarPickerHeaderView { [weak self] in
        guard let self = self else { return }
// ??????header view???closeBtn?????????
        self.dismiss(animated: true)
    }
    
    lazy var footerView = CalendarPickerFooterView { [weak self] in
        guard let self = self else { return }
        // confirm Date Range!
        self.passDateDelegate?.passDateRange(dateRange: self.selectedDates)
        self.passDateToDetailVCDelegate?.passDateRangeToDetailVC(dateRange: self.selectedDates)
        self.dismiss(animated: true)
    }

  // MARK: Calendar Data Values

    private var todayDate: Date {
        didSet {
            days = generateDaysInMonth(for: todayDate)
            dateCollectionView.reloadData()
        }
    }

    private lazy var days = generateDaysInMonth(for: todayDate)
    private var secondMonthDays = [Day]()
    private var thirdMonthDays = [Day]()

    private var numberOfWeeksInTodayDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: todayDate)?.count ?? 0
    }

    private let calendar = Calendar(identifier: .gregorian)

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()

  // MARK: Initializers

    init(todayDate: Date) {
        self.todayDate = todayDate

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        definesPresentationContext = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dateCollectionView.register(CalendarSectionHeaderView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: CalendarSectionHeaderView.reuseIdentifier)
        
        dateCollectionView.backgroundColor = .systemGroupedBackground
      
        view.addSubview(dimmedBackgroundView)
        view.addSubview(dateCollectionView)
        view.addSubview(headerView)
        view.addSubview(footerView)

        var constraints = [dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                           dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                           dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                           dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                        ]

        constraints.append(contentsOf: [
            dateCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            dateCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            dateCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
            dateCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])

        constraints.append(contentsOf: [
            headerView.leadingAnchor.constraint(equalTo: dateCollectionView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: dateCollectionView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: dateCollectionView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
      
            footerView.leadingAnchor.constraint(equalTo: dateCollectionView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: dateCollectionView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: dateCollectionView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 60)
        ])

        NSLayoutConstraint.activate(constraints)

        dateCollectionView.register(CalendarCollectionCell.self,
                                    forCellWithReuseIdentifier: CalendarCollectionCell.reuseIdentifier)

        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.backgroundColor = .white
        headerView.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let nextMonthDay = calendar.date(byAdding: .month, value: 1, to: todayDate),
              let nextNextMonthDay = calendar.date(byAdding: .month, value: 1, to: nextMonthDay) else { return }
        secondMonthDays = generateDaysInMonth(for: nextMonthDay)
        thirdMonthDays = generateDaysInMonth(for: nextNextMonthDay)
        
    }
}

// MARK: - Day Generation
extension CalendarPickerViewController {
  // 1
    func monthMetadata(for todayDate: Date) throws -> MonthMetadata {
    // 2
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: todayDate)?.count,
              let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: todayDate)) else {
                    throw CalendarDataError.metadataGeneration
                }
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)

    return MonthMetadata(
        numberOfDays: numberOfDaysInMonth,
        firstDay: firstDayOfMonth,
        firstDayWeekday: firstDayWeekday)
    }

  // 1
    func generateDaysInMonth(for todayDate: Date) -> [Day] {
    // 2
        guard let metadata = try? monthMetadata(for: todayDate) else {
            preconditionFailure("An error occurred when generating the metadata for \(todayDate)")
        }
        
        let numberOfDaysInMonth = metadata.numberOfDays  // ???????????????
        let offsetInInitialRow = metadata.firstDayWeekday // ?????????????????????????????????
        let firstDayOfMonth = metadata.firstDay // ??????????????????

    // 3
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
        // 4
                let isWithinDisplayedMonth = day >= offsetInInitialRow // ?????????????????????????????????????????? ???????????????!
        // 5
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
        // 6
                return generateDay(
                    offsetBy: dayOffset,
                    for: firstDayOfMonth,
                    isWithinDisplayedMonth: isWithinDisplayedMonth)
            }
            days += generateStartOfNextMonth(using: firstDayOfMonth)

            return days
        }

  // 7
    func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        if let rentAvailableDate = rentAvailableDate {
            // ???????????????????????????????????????
            let dateString = dateFormatter2.string(from: date)
            let isSubsetOfAvailableSet = dateStringArray.contains(dateString)
            // ??????????????????????????????
            let isDateNotPass = date.addingTimeInterval(86400) >= Date()
            
            return Day(
                date: date,
                number: dateFormatter.string(from: date),
                isSelectable: isWithinDisplayedMonth && isSubsetOfAvailableSet && isDateNotPass,
                isWithinDisplayedMonth: isWithinDisplayedMonth
            )
        } else {
            // ??????????????????????????????
            let isDateNotPass = date.addingTimeInterval(86400) >= Date()

            return Day(
                date: date,
                number: dateFormatter.string(from: date),
                isSelectable: isWithinDisplayedMonth && isDateNotPass,
                isWithinDisplayedMonth: isWithinDisplayedMonth
            )
        }
    }

  // 1
    func generateStartOfNextMonth(
        using firstDayOfDisplayedMonth: Date
        ) -> [Day] {
    // 2
            guard let lastDayInMonth = calendar.date(
                byAdding: DateComponents(month: 1, day: -1),
                to: firstDayOfDisplayedMonth) else { return [] }

    // 3
            let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
            guard additionalDays > 0 else { return [] }

    // 4
            let days: [Day] = (1...additionalDays)
                .map {
                    generateDay(
                        offsetBy: $0,
                        for: lastDayInMonth,
                        isWithinDisplayedMonth: false)
                }
            return days
        }

    enum CalendarDataError: Error {
        case metadataGeneration
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarPickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return days.count
        case 1:
            return secondMonthDays.count
        case 2:
            return thirdMonthDays.count
        default:
            return days.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let day = days[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarCollectionCell.reuseIdentifier,
                for: indexPath) as? CalendarCollectionCell else { fatalError() }
            cell.selectedState = false
            cell.isInRange = false
            cell.day = day
            
            for selectedDate in selectedDates where cell.day?.date == selectedDate && day.isWithinDisplayedMonth {
                cell.selectedState = true
            }

            if selectedDates.count == 2 {
                guard let startDate = selectedDates.first,
                      let endDate = selectedDates.last else { return cell}
                if startDate <= day.date && day.date <= endDate && day.isWithinDisplayedMonth {
                    cell.isInRange = true
                    if day.date == startDate {
                        cell.rangeLeftView.isHidden = true
                    } else if day.date == endDate {
                        cell.rangeRightView.isHidden = true
                    }
                }
            }
            
            return cell
        case 1:
            let day = secondMonthDays[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarCollectionCell.reuseIdentifier,
                for: indexPath) as? CalendarCollectionCell else { fatalError() }
            cell.selectedState = false
            cell.isInRange = false
            cell.day = day
            
            for selectedDate in selectedDates where cell.day?.date == selectedDate && day.isWithinDisplayedMonth {
                cell.selectedState = true
            }

            if selectedDates.count == 2 {
                guard let startDate = selectedDates.first,
                      let endDate = selectedDates.last else { return cell}
                print(startDate)
                print(endDate)
                print(day.date)
                if startDate <= day.date && day.date <= endDate && day.isWithinDisplayedMonth {
                    cell.isInRange = true
                    if day.date == startDate {
                        cell.rangeLeftView.isHidden = true
                    } else if day.date == endDate {
                        cell.rangeRightView.isHidden = true
                    }
                }
            }
            return cell
        case 2:
            let day = thirdMonthDays[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarCollectionCell.reuseIdentifier,
                for: indexPath) as? CalendarCollectionCell else { fatalError() }
            cell.selectedState = false
            cell.isInRange = false
            cell.day = day
            
            for selectedDate in selectedDates where cell.day?.date == selectedDate && day.isWithinDisplayedMonth {
                cell.selectedState = true
            }

            if selectedDates.count == 2 {
                guard let startDate = selectedDates.first,
                      let endDate = selectedDates.last else { return cell}
                if startDate <= day.date && day.date <= endDate && day.isWithinDisplayedMonth {
                    cell.isInRange = true
                    if day.date == startDate {
                        cell.rangeLeftView.isHidden = true
                    } else if day.date == endDate {
                        cell.rangeRightView.isHidden = true
                    }
                }
            }
            return cell
        default:
            let day = days[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarCollectionCell.reuseIdentifier,
                for: indexPath) as? CalendarCollectionCell else { fatalError() }

            cell.day = day
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CalendarSectionHeaderView.reuseIdentifier,
            for: indexPath) as? CalendarSectionHeaderView else { fatalError() }
        switch indexPath.section {
        case 0:
            sectionHeaderView.todayDate = todayDate
        case 1:
            guard let nextMonthDay = calendar.date(byAdding: .month, value: 1, to: todayDate)
            else { return sectionHeaderView }
            sectionHeaderView.todayDate = nextMonthDay
            
        case 2:
            guard let nextNextMonthDay = calendar.date(byAdding: .month, value: 2, to: todayDate)
            else { return sectionHeaderView }
            sectionHeaderView.todayDate = nextNextMonthDay
        default:
            sectionHeaderView.todayDate = todayDate
        }
        
        return sectionHeaderView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarPickerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionCell,
              let day = cell.day else { return }
        guard day.isSelectable else { return }
        
        switch selectedCount {
        case 2:
            collectionView.visibleCells.forEach { selectedCell in
                guard let selectedCell = selectedCell as? CalendarCollectionCell else { return }
                selectedCell.isInRange = false
                selectedCell.selectedState = false
                selectedCell.applyDefaultStyle(
                    isWithinDisplayedMonth: selectedCell.day?.isWithinDisplayedMonth ?? true)
            }
            selectedDates = []
            selectedCount = 0
            selectedDates.insert(day.date, at: selectedCount)
            cell.selectedState = true
            selectedCount += 1
        case 1:
            guard let startDate = selectedDates.first else { return}
            if startDate < day.date {
                selectedDates.insert(day.date, at: selectedCount)
                cell.selectedState = true
                collectionView.reloadData()
                selectedCount += 1
            } else {
                collectionView.visibleCells.forEach { selectedCell in
                    guard let selectedCell = selectedCell as? CalendarCollectionCell else { return }
                    selectedCell.selectedState = false
                    selectedCell.applyDefaultStyle(
                        isWithinDisplayedMonth: selectedCell.day?.isWithinDisplayedMonth ?? true)
                }
                selectedDates = []
                selectedCount = 0
                selectedDates.insert(day.date, at: selectedCount)
                cell.selectedState = true
                selectedCount += 1
            }
        case 0:
            selectedDates.insert(day.date, at: selectedCount)
            cell.selectedState = true
            selectedCount += 1
        default:
            print("default")
        }
        print(selectedDates)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInTodayDate
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 60)
    }
}
// swiftlint:disable cyclomatic_complexity
