//
//  CalendarViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/15.
//

import Foundation
import UIKit

protocol PassDateRangeToDetailVCDelegate: AnyObject {
    func passDateRangeToDetailVC(dateRange: [Date])
}

protocol PassDateRangeToPostVCDelegate {
    func passDateRangeToPostVC(dateRange: [Date])
}

class CalendarPickerViewController: UIViewController {
    let dateFormatterForSet: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
        return dateFormatter
    }()
    
    var rentAvailableDateStrings = [String]()
    
    var rentAvailableDates: [Date]? {
        didSet {
            rentAvailableDateStrings = []
            guard let rentAvailableDates = rentAvailableDates else { return }
            for date in rentAvailableDates {
                let dateString = dateFormatterForSet.string(from: date)
                rentAvailableDateStrings.append(dateString)
            }
        }
    }
    
    var passDateToDetailVCDelegate: PassDateRangeToDetailVCDelegate?
    var passDateToPostVCDelegate: PassDateRangeToPostVCDelegate?
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
// 定義header view的closeBtn的閉包
        self.dismiss(animated: true)
    }
    
    lazy var footerView = CalendarPickerFooterView { [weak self] in
        guard let self = self else { return }
        // confirm Date Range!
        self.passDateToPostVCDelegate?.passDateRangeToPostVC(dateRange: self.selectedDates)
        self.passDateToDetailVCDelegate?.passDateRangeToDetailVC(dateRange: self.selectedDates)
        self.dismiss(animated: true)
    }

  // MARK: Calendar Data Values
    private var todayDate: Date {
        didSet {
            dateCollectionView.reloadData()
        }
    }

    private lazy var firstMonthDays = generateDaysInMonth(for: todayDate)
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
        dateCollectionView.register(CalendarCollectionCell.self,
                                    forCellWithReuseIdentifier: CalendarCollectionCell.reuseIdentifier)

        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        dateCollectionView.backgroundColor = .white
      
        view.addSubview(dimmedBackgroundView)
        view.addSubview(dateCollectionView)
        view.addSubview(headerView)
        view.addSubview(footerView)
        
        dimmedBackgroundView.addConstraintsToFillView(view)
        
        dateCollectionView.anchor(leading: view.leadingAnchor,
                                  trailing: view.trailingAnchor,
                                  paddingLeading: 30,
                                  paddingTrailing: 30)
        
        headerView.anchor(leading: dateCollectionView.leadingAnchor,
                          bottom: dateCollectionView.topAnchor,
                          trailing: dateCollectionView.trailingAnchor,
                          height: 50)
        
        footerView.anchor(top: dateCollectionView.bottomAnchor,
                          leading: dateCollectionView.leadingAnchor,
                          trailing: dateCollectionView.trailingAnchor,
                          height: 60)

        let constraints = [dateCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                                                        constant: 10),
                           dateCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                                      multiplier: 0.4)]
        NSLayoutConstraint.activate(constraints)
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
    func getMonthMetadata(for todayDate: Date) throws -> MonthMetadata {
        guard let numberOfDaysInMonth = calendar.range(of: .day,
                                                       in: .month,
                                                       for: todayDate)?.count,
              let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: todayDate)) else {
                    throw CalendarDataError.metadataGeneration
                }
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)

    return MonthMetadata(numberOfDays: numberOfDaysInMonth,
                         firstDay: firstDayOfMonth,
                         firstDayWeekday: firstDayWeekday)
    }

    func generateDaysInMonth(for todayDate: Date) -> [Day] {
        guard let monthMetadata = try? getMonthMetadata(for: todayDate) else {
            preconditionFailure("An error occurred when generating the metadata for \(todayDate)")
        }
        let numberOfDaysInMonth = monthMetadata.numberOfDays  // 本月共幾天
        let offsetInInitialRow = monthMetadata.firstDayWeekday // 本月第一天所在的工作天
        let firstDayOfMonth = monthMetadata.firstDay // 本月的第一天

        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow)).map { day in
            let isWithinDisplayedMonth = day >= offsetInInitialRow // 大於本月第一天所在的工作天者 為此月範圍!
            let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
            
            return generateDay( offsetBy: dayOffset,
                                for: firstDayOfMonth,
                                isWithinDisplayedMonth: isWithinDisplayedMonth)
        }
        days += createStartDaysOfNextMonthToFillRestItem(using: firstDayOfMonth)

        return days
    }
    
    func createStartDaysOfNextMonthToFillRestItem(using firstDayOfDisplayedMonth: Date) -> [Day] {
        // get the last weekday of this month!
        guard let lastDayInThisMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                                 to: firstDayOfDisplayedMonth) else { return [] }
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInThisMonth)
        guard additionalDays > 0 else { return [] }
        
        // fill this month collection item by additional days
        let days: [Day] = (1...additionalDays).map {
            generateDay(offsetBy: $0, for: lastDayInThisMonth, isWithinDisplayedMonth: false)
        }
        return days
    }
    
    func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        if rentAvailableDates != nil { // can improve read avility
            // 判斷日期是否在可租借的區間
            let dateString = dateFormatterForSet.string(from: date)
            let isSubsetOfAvailableSet = rentAvailableDateStrings.contains(dateString)
            // 判斷日期是否大於今天
            let isDateNotPassed = date.addingTimeInterval(86400) >= Date()
            
            return Day(date: date,
                       number: dateFormatter.string(from: date),
                       isSelectable: isWithinDisplayedMonth && isSubsetOfAvailableSet && isDateNotPassed,
                       isWithinDisplayedMonth: isWithinDisplayedMonth)
        } else {
            // 判斷日期是否大於今天
            let isDateNotPass = date.addingTimeInterval(86400) >= Date()
            
            return Day(date: date,
                       number: dateFormatter.string(from: date),
                       isSelectable: isWithinDisplayedMonth && isDateNotPass,
                       isWithinDisplayedMonth: isWithinDisplayedMonth)
        }
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
            return firstMonthDays.count
        case 1:
            return secondMonthDays.count
        case 2:
            return thirdMonthDays.count
        default:
            return firstMonthDays.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarCollectionCell.reuseIdentifier,
            for: indexPath) as? CalendarCollectionCell else { fatalError() }
        guard let monthOfCalendar = MonthOfCalendar(rawValue: indexPath.section) else { return cell}
        switch monthOfCalendar {
        case .first:
            cell.resetCell()
            let day = firstMonthDays[indexPath.row]
            cell.day = day
            selectBothEndsDate(for: cell, cellDay: day)
            return drawCellInChooseDateRange(for: cell, day: day, in: selectedDates)
            
        case .second:
            cell.resetCell()
            let day = secondMonthDays[indexPath.row]
            cell.day = day
            selectBothEndsDate(for: cell, cellDay: day)
            return drawCellInChooseDateRange(for: cell, day: day, in: selectedDates)
            
        case .third:
            cell.resetCell()
            let day = thirdMonthDays[indexPath.row]
            cell.day = day
            selectBothEndsDate(for: cell, cellDay: day)
            return drawCellInChooseDateRange(for: cell, day: day, in: selectedDates)
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
            cleanVisibleCell(collectionView: collectionView)
            reinsertStartDate(select: cell, selectStartDate: day.date)
        case 1:
            guard let startDate = selectedDates.first else { return}
            if startDate < day.date {
                selectDate(in: cell, at: day)
                collectionView.reloadData()  // reload to draw the rang view!
            } else {
                cleanVisibleCell(collectionView: collectionView)
                reinsertStartDate(select: cell, selectStartDate: day.date)
            }
        case 0:
            selectDate(in: cell, at: day)
        default:
            print("default")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInTodayDate
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 60)
    }
}

// collection dataSource relate func
extension CalendarPickerViewController {
    func selectBothEndsDate(for cell: CalendarCollectionCell, cellDay: Day) {
        for selectedDate in selectedDates where cell.day?.date == selectedDate && cellDay.isWithinDisplayedMonth {
            cell.selectedState = true
        }
    }
    
    func drawCellInChooseDateRange(for cell: CalendarCollectionCell,
                                   day: Day,
                                   in selectedDates: [Date]) -> CalendarCollectionCell {
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
    }
    
    func reinsertStartDate(select cell: CalendarCollectionCell, selectStartDate: Date) {
        selectedDates = []
        selectedCount = 0
        selectedDates.insert(selectStartDate, at: selectedCount)
        cell.selectedState = true
        selectedCount += 1
    }
    
    func cleanVisibleCell(collectionView: UICollectionView) {
        collectionView.visibleCells.forEach { selectedCell in
            guard let selectedCell = selectedCell as? CalendarCollectionCell else { return }
            selectedCell.isInRange = false
            selectedCell.selectedState = false
            selectedCell.applyDefaultStyle(
                isWithinDisplayedMonth: selectedCell.day?.isWithinDisplayedMonth ?? true)
        }
    }
    
    func selectDate(in cell: CalendarCollectionCell, at day: Day) {
        selectedDates.insert(day.date, at: selectedCount)
        cell.selectedState = true
        selectedCount += 1
    }
}
