//
//  BookingInfoTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit

class BookingInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lessorNameLabel: UILabel!
    @IBOutlet weak var leaseDate: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
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
