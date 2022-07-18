//
//  CalendarCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/15.
//

import Foundation
import UIKit

class CalendarCollectionCell: UICollectionViewCell {
    
    var rangeLeftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.OutdoorTribeColor.mainColor.withAlphaComponent(0.2)
        view.isHidden = true
        return view
    }()
    
    var rangeRightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.OutdoorTribeColor.mainColor.withAlphaComponent(0.2)
        view.isHidden = true
        return view
    }()
    
    var isInRange = false {
        didSet {
            if isInRange {
                rangeLeftView.isHidden = !isInRange
                rangeRightView.isHidden = !isInRange
            } else {
                rangeLeftView.isHidden = !isInRange
                rangeRightView.isHidden = !isInRange
            }
        }
    }

    var selectedState = false {
        didSet {
            numberLabel.textColor = selectedState ? .white : UIColor.OutdoorTribeColor.mainColor
            selectionBackgroundView.isHidden = !selectedState
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
        contentView.addSubview(rangeLeftView)
        contentView.addSubview(rangeRightView)
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    // This allows for rotations and trait collection
    // changes (e.g. entering split view on iPad) to update constraints correctly.
    // Removing old constraints allows for new ones to be created
    // regardless of the values of the old ones
        NSLayoutConstraint.deactivate(selectionBackgroundView.constraints)

    // 1
        let size = traitCollection.horizontalSizeClass == .compact ?
        min(min(frame.width, frame.height) - 10, 60) : 45

    // 2
        NSLayoutConstraint.activate([
            
            rangeLeftView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rangeLeftView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rangeLeftView.trailingAnchor.constraint(equalTo: centerXAnchor),
            rangeLeftView.heightAnchor.constraint(equalToConstant: 45),
            
            rangeRightView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rangeRightView.leadingAnchor.constraint(equalTo: centerXAnchor),
            rangeRightView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rangeRightView.heightAnchor.constraint(equalToConstant: 45),
            
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
extension CalendarCollectionCell {
  
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
