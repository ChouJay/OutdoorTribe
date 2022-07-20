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
    func passDateRangeToVC()
}

class InfoTableViewCell: UITableViewCell {
    var passDateDelegate: PassDateToPostVCDelegate?
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var classificationTextField: UITextField!
    
    @IBOutlet weak var datePickerBtn: UIButton!
    @IBOutlet weak var dateRangeTextField: UITextField!
    
    @IBOutlet weak var pullDownBtn: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpPullDownBtn()
        layoutTextView()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func tapDateRangePicker(_ sender: Any) {
        passDateDelegate?.passDateRangeToVC()
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
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = true
        descriptionTextView.isScrollEnabled = false
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
extension InfoTableViewCell: AskInfoCellDelegate {
    func askToShowDateRange(dateRange: [Date]) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy/MM/dd")
        
        let beginDateString = dateFormatter.string(from: dateRange.first ?? Date())
        let endDateString = dateFormatter.string(from: dateRange.last ?? Date())
        dateRangeTextField.text = " \(beginDateString)" + " - " + "\(endDateString)"
    }
    
    func askToDiscardInfo() {
        descriptionTextView.textColor = .lightGray
        descriptionTextView.text = "description"
        titleTextField.text = ""
        amountTextField.text = ""
        addressTextField.text = ""
        classificationTextField.text = ""
        dateRangeTextField.text = ""
    }
}
