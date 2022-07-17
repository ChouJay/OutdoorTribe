//
//  CalendarFilterHeaderView.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/17.
//

import Foundation
import UIKit

class CalendarFilterHeaderView: UIView {
    
    static let reuseIdentifier =  String(describing: CalendarFilterHeaderView.self)
    
    var startLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = " from: "
        label.textColor = UIColor.OutdoorTribeColor.mainColor
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        return label
    }()
    
    var endLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = " to: "
        label.textColor = UIColor.OutdoorTribeColor.mainColor
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return label
    }()
    
    var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 2
    
        return stackView
    }()
            
    var dayOfWeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    var todayDate = Date()
    var exitButtonTappedCompletionHandler: (() -> Void)
    
    func setUpStackView() {
        labelStackView.addArrangedSubview(startLabel)
        labelStackView.addArrangedSubview(endLabel)
    }

    init(exitButtonTappedCompletionHandler: @escaping (() -> Void)) {
        self.exitButtonTappedCompletionHandler = exitButtonTappedCompletionHandler

        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .systemGroupedBackground

        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15

        addSubview(labelStackView)
        addSubview(separatorView)
        
        setUpStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dayOfWeekLetter(for dayNumber: Int) -> String {
        switch dayNumber {
        case 1:
            return "S"
        case 2:
            return "M"
        case 3:
            return "T"
        case 4:
            return "W"
        case 5:
            return "T"
        case 6:
            return "F"
        case 7:
            return "S"
        default:
            return ""
        }
    }
    
    @objc func didTapExitButton() {
      exitButtonTappedCompletionHandler()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),

            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
