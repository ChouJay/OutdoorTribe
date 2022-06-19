//
//  DetailInfoTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/18.
//

import UIKit

class DetailInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
