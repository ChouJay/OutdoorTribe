//
//  DetailInfoTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/18.
//

import UIKit

protocol PassDateToVcDelegate {
    func getStartDate(_ datePicker: UIDatePicker)
    func getEndDate(_ datePicker: UIDatePicker)
}

class DetailInfoTableViewCell: UITableViewCell {

    var delegate: PassDateToVcDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!

    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setRentLimitedPeriod(head: Date, tail: Date) {
        startDatePicker.minimumDate = head
        startDatePicker.maximumDate = tail
        endDatePicker.minimumDate = head
        endDatePicker.maximumDate = tail
        startDatePicker.addTarget(self, action: #selector(startDateChange), for: .allEditingEvents)
        endDatePicker.addTarget(self, action: #selector(endDateChange), for: .allEditingEvents)
    }
    
    @objc func startDateChange() {
        delegate?.getStartDate(startDatePicker)
    }
    
    @objc func endDateChange() {
        delegate?.getEndDate(endDatePicker)
    }

}
