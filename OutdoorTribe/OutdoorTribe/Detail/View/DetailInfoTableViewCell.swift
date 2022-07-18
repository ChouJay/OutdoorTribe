//
//  DetailInfoTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/18.
//

import UIKit

protocol askDetailVCPresentDateRangeDelegate {
    func askDetailVCPresentDateRangePicker()
    func passAmountToVC(requireAmount: String)
}

class DetailInfoTableViewCell: UITableViewCell {

    var delegate: askDetailVCPresentDateRangeDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateRangeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func tapDateRangeBtn(_ sender: Any) {
        delegate?.askDetailVCPresentDateRangePicker()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTextFieldDelegate()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setTextFieldDelegate() {
        amountTextField.delegate = self
    }
}

// MARK: - be asked to show date range delegate
extension DetailInfoTableViewCell: AskDetailInfoCellDelegate {
    func askDetailCellToShowDateRange(dateRange: [Date]) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy/MM/dd")
        
        let beginDateString = dateFormatter.string(from: dateRange.first ?? Date())
        let endDateString = dateFormatter.string(from: dateRange.last ?? Date())
        dateRangeTextField.text = " \(beginDateString)" + " - " + "\(endDateString)"
    }
}

// MARK: textField Delegate
extension DetailInfoTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.passAmountToVC(requireAmount: amountTextField.text ?? "0")
    }
}


