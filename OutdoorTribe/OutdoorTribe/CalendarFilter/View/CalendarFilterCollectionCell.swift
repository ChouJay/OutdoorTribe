//
//  CalendarFilterCollectionCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/17.
//

import Foundation
import UIKit

class CalendarFilterCollectionCell: UICollectionViewCell {
    
    var rangeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.OutdoorTribeColor.mainColor.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()
    
    var selectedState = false {
        didSet {
            numberLabel.textColor = selectedState ? .white : UIColor.OutdoorTribeColor.mainColor
            selectionBackgroundView.isHidden = !selectedState
        }
    }
    
    var isInRange = false {
        didSet {
            if isInRange {
                rangeView.isHidden = !isInRange
            } else {
                rangeView.isHidden = !isInRange
            }
        }
    }
    
    var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = UIColor.OutdoorTribeColor.mainColor
        return view
    }()

    var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor.OutdoorTribeColor.mainColor
        return label
    }()

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()

    static let reuseIdentifier = String(describing: CalendarCollectionCell.self)

    var day: Day? {
        didSet {
            guard var day = day else { return }
            if !day.isWithinDisplayedMonth {
                day.date = Date(timeIntervalSince1970: 1)
                day.number = String("")
            }
            numberLabel.text = day.number
            applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(rangeView)
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.deactivate(selectionBackgroundView.constraints)

    // 1
//        let size = traitCollection.horizontalSizeClass == .compact ?
//        min(min(frame.width, frame.height) - 10, 60) : 45

    // 2
        NSLayoutConstraint.activate([
            
            rangeView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rangeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rangeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rangeView.heightAnchor.constraint(equalToConstant: 45),
            
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: 45),
            selectionBackgroundView.heightAnchor.constraint(equalTo: selectionBackgroundView.widthAnchor)
        ])

        selectionBackgroundView.layer.cornerRadius = 45 / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layoutSubviews()
    }
}

// MARK: - Appearance
extension CalendarFilterCollectionCell {
  
  // 2
    var isSmallScreenSize: Bool {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let smallWidth = UIScreen.main.bounds.width <= 350
        let widthGreaterThanHeight = UIScreen.main.bounds.width > UIScreen.main.bounds.height

        return isCompact && (smallWidth || widthGreaterThanHeight)
    }
    
  // 4
    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        guard let isSelectable = day?.isSelectable else { return }
//        numberLabel.textColor = isWithinDisplayedMonth ? UIColor.OutdoorTribeColor.mainColor : .clear
        numberLabel.textColor = isSelectable ? UIColor.OutdoorTribeColor.mainColor : .lightGray
    }
}
