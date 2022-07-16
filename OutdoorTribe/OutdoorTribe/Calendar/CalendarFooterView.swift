//
//  CalendarFooterView.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/15.
//

import Foundation
import UIKit

class CalendarPickerFooterView: UIView {
    var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.label.withAlphaComponent(0.2)
        return view
    }()

    var confirmButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.setTitle("Confirm", for: .normal)
        button.titleLabel?.textColor = .label

        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        return button
    }()
    
    let didTapConfirmCompletionHandler: (() -> Void)

    init(didTapConfirmCompletionHandler: @escaping (() -> Void)) {
        self.didTapConfirmCompletionHandler = didTapConfirmCompletionHandler
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGroupedBackground

        layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        addSubview(separatorView)
        addSubview(confirmButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let fontPointSize: CGFloat = 17

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            confirmButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            confirmButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            confirmButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc func didTapConfirmButton() {
        didTapConfirmCompletionHandler()
    }
}
