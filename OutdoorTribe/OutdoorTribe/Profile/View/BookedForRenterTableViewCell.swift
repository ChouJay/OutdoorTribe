//
//  BookedForRenterTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/28.
//

import UIKit

protocol RenterChangeStateDelegate {
    func askVcChangeToDeliveredState(_ sender: UIButton)
    func askVcToCancelRenterOrder(_ orderID: String)
}

class BookedForRenterTableViewCell: UITableViewCell {
    
    var orderID = ""
    var changeStateDelegate: RenterChangeStateDelegate?
    
    @IBOutlet weak var deliverBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var pickUpdateLabel: UILabel!
    
    @IBAction func tapDeliverBtn(_ sender: UIButton) {
        changeStateDelegate?.askVcChangeToDeliveredState(sender)
    }
    @IBAction func tapCancelBtn(_ sender: Any) {
        changeStateDelegate?.askVcToCancelRenterOrder(orderID)
    }
    
    override func prepareForReuse() {
        enableDeliverBtn()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutStuff()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func layoutStuff() {
        photoImage.layer.cornerRadius = 10
        deliverBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
    }
    
    func disableDeliverBtn() {
        deliverBtn.isEnabled = false
        deliverBtn.backgroundColor = .gray
    }
    
    func enableDeliverBtn() {
        deliverBtn.isEnabled = true
        deliverBtn.backgroundColor = UIColor.OutdoorTribeColor.btnEnableColor
    }
}
