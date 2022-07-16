//
//  CalendarViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/15.
//

import Foundation
import UIKit

class CalendarPickerViewController: UIViewController {
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
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        return collectionView
    }()

    lazy var headerView = CalendarPickerHeaderView { [weak self] in
        guard let self = self else { return }
// 定義header view的closeBtn的閉包
        self.dismiss(animated: true)
    }

    
    lazy var footerView = CalendarPickerFooterView { [weak self] in
        guard let self = self else { return }
        // confirm Date filter!
        
    }

  // MARK: Calendar Data Values

    private var todayDate: Date {
        didSet {
            days = generateDaysInMonth(for: todayDate)
            dateCollectionView.reloadData()
            headerView.todayDate = todayDate
        }
    }

    private lazy var days = generateDaysInMonth(for: todayDate)

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
      //1
            dateCollectionView.leadingAnchor.constraint(
            equalTo: view.readableContentGuide.leadingAnchor),
            dateCollectionView.trailingAnchor.constraint(
                equalTo: view.readableContentGuide.trailingAnchor),
      //2
            dateCollectionView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: 10),
      //3
            dateCollectionView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.5)
        ])

        constraints.append(contentsOf: [
            headerView.leadingAnchor.constraint(equalTo: dateCollectionView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: dateCollectionView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: dateCollectionView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 85),
      
            footerView.leadingAnchor.constraint(equalTo: dateCollectionView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: dateCollectionView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: dateCollectionView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 60)
        ])

        NSLayoutConstraint.activate(constraints)

        dateCollectionView.register(CalendarCollectionCell.self, forCellWithReuseIdentifier: CalendarCollectionCell.reuseIdentifier)

        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        headerView.todayDate = todayDate
    }
}

// MARK: - Day Generation
private extension CalendarPickerViewController {
  // 1
    func monthMetadata(for todayDate: Date) throws -> MonthMetadata {
    // 2
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for:     todayDate)?.count,
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: todayDate)) else { throw CalendarDataError.metadataGeneration }
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
        
        let numberOfDaysInMonth = metadata.numberOfDays  // 本月共幾天
        let offsetInInitialRow = metadata.firstDayWeekday // 本月第一天所在的工作天
        let firstDayOfMonth = metadata.firstDay // 本月的第一天

    // 3
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
        // 4
                let isWithinDisplayedMonth = day >= offsetInInitialRow // 大於本月第一天所在的工作天者 為此月範圍!
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
    func generateDay(
        offsetBy dayOffset: Int,
        for baseDate: Date,
        isWithinDisplayedMonth: Bool
    ) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate

        return Day(
            date: date,
            number: dateFormatter.string(from: date),
            isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }

  // 1
    func generateStartOfNextMonth(
        using firstDayOfDisplayedMonth: Date
        ) -> [Day] {
    // 2
            guard let lastDayInMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),to: firstDayOfDisplayedMonth) else { return [] }

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
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    days.count
  }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let day = days[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionCell.reuseIdentifier, for: indexPath) as? CalendarCollectionCell else { fatalError() }
    // swiftlint:disable:previous force_cast

        cell.day = day
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let day = days[indexPath.row]

    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInTodayDate
        return CGSize(width: width, height: height)
    }
}
