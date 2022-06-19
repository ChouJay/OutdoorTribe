//
//  InfoTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var rentTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var beginDateTextField: UITextField!
    @IBOutlet weak var lastDateTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDatePicker(dateTextField: beginDateTextField)
        setDatePicker(dateTextField: lastDateTextField)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        beginDateTextField.text = formatDate(date: datePicker.date)
        beginDateTextField.resignFirstResponder()
        
        // Replace the hour (time) of both dates with 00:00
    }
    
    @objc func dateChangeForLast(datePicker: UIDatePicker) {
        lastDateTextField.text = formatDate(date: datePicker.date)
        lastDateTextField.resignFirstResponder()

    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter.string(from: date)
    }
    
    func setDatePicker(dateTextField: UITextField) {
        if dateTextField == beginDateTextField {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
            datePicker.frame.size = CGSize(width: 0, height: 500)
            datePicker.preferredDatePickerStyle = .inline
            beginDateTextField.inputView = datePicker
        } else {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChangeForLast(datePicker:)), for: .valueChanged)
            datePicker.frame.size = CGSize(width: 0, height: 500)
            datePicker.preferredDatePickerStyle = .inline
            lastDateTextField.inputView = datePicker
        }
    }
}
