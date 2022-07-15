//
//  InfoTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import UIKit

protocol PassDateToPostVCDelegate {
    func passEndDateToVC(chooseDate: Date)
    func passStartDateToVC(chooseDate: Date)
    func passClassificationToVC(text: String)
}

class InfoTableViewCell: UITableViewCell {

    var passDateDelegate: PassDateToPostVCDelegate?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var classificationTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var pullDownBtn: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDatePickerValueChange()
        setUpPullDownBtn()
        layoutTextView()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        passDateDelegate?.passStartDateToVC(chooseDate: datePicker.date)
        // Replace the hour (time) of both dates with 00:00
    }
    
    @objc func dateChangeForLast(datePicker: UIDatePicker) {
        // call delegate func to pass date to VC
        passDateDelegate?.passEndDateToVC(chooseDate: datePicker.date)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter.string(from: date)
    }
    
    func layoutTextView() {
        descriptionTextView.textColor = .lightGray
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    func setDatePickerValueChange() {
        startDatePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(dateChangeForLast(datePicker:)), for: .valueChanged)
    }
    
    func setUpPullDownBtn() {
        pullDownBtn.showsMenuAsPrimaryAction = true
        pullDownBtn.menu = UIMenu(children: [
            UIAction(title: "Camping", handler: { [weak self] action in
                self?.classificationTextField.text = action.title
                self?.passDateDelegate?.passClassificationToVC(text: action.title)
        }),
            UIAction(title: "Hiking", handler: { [weak self] action in
                self?.classificationTextField.text = action.title
                self?.passDateDelegate?.passClassificationToVC(text: action.title)
        }),
            UIAction(title: "Climbing", handler: { [weak self] action in
                self?.classificationTextField.text = action.title
                self?.passDateDelegate?.passClassificationToVC(text: action.title)
        }),
            UIAction(title: "Skiing", handler: { [weak self] action in
                self?.classificationTextField.text = action.title
                self?.passDateDelegate?.passClassificationToVC(text: action.title)
        }),
            UIAction(title: "Diving", handler: { [weak self] action in
                self?.classificationTextField.text = action.title
                self?.passDateDelegate?.passClassificationToVC(text: action.title)
        }),
            UIAction(title: "Surfing", handler: { [weak self] action in
                self?.classificationTextField.text = action.title
                self?.passDateDelegate?.passClassificationToVC(text: action.title)
        }),
            UIAction(title: "Others", handler: { [weak self] action in
                self?.classificationTextField.text = action.title
                self?.passDateDelegate?.passClassificationToVC(text: action.title)
        })])
    }
}

// MARK: - discard delegate
extension InfoTableViewCell: DiscardDelegate {
    func askToDiscardInfo() {
        descriptionTextView.textColor = .lightGray
        descriptionTextView.text = "Description"
        titleTextField.text = ""
        amountTextField.text = ""
        addressTextField.text = ""
        classificationTextField.text = ""
        startDatePicker.date = .now
        endDatePicker.date = .now
    }
}
