//
//  BookedForRenterTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/28.
//

import UIKit

protocol RenterChangeStateDelegate {
    func askVcChangeToDeliveredState(_ sender: UIButton)
    func askVcToCancelRenterOrder(_ sender: UIButton)
}

class BookedForRenterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deliverBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    
    var changeStateDelegate: RenterChangeStateDelegate?
    
    @IBAction func tapDeliverBtn(_ sender: UIButton) {
        changeStateDelegate?.askVcChangeToDeliveredState(sender)
    }
    @IBAction func tapCancelBtn(_ sender: Any) {
    }
    
    override func prepareForReuse() {
        enableDeliverBtn()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func disableDeliverBtn() {
        deliverBtn.isEnabled = false
        deliverBtn.backgroundColor = .gray
    }
    
    func enableDeliverBtn() {
        deliverBtn.isEnabled = true
        deliverBtn.backgroundColor = UIColor(red: 146 / 250, green: 182 / 250, blue: 137 / 250, alpha: 1)
    }
}
