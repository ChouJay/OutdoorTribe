//
//  BookingStageTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit

protocol LessorChangeStateDelegate {
    func askVcChangeToPickUpState(_ sender: UIButton)
    func askVcToCancelLessorOrder(_ orderID: String)
}

class BookedForLessorTableViewCell: UITableViewCell {

    var orderID = ""
    var changeStateDelegate: LessorChangeStateDelegate?
    
    @IBOutlet weak var bookedPhoto: UIImageView!
    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var lessorCancelBtn: UIButton!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var pickUpDateLabel: UILabel!
    
    @IBAction func tapPickUpButton(_ sender: UIButton) {
        changeStateDelegate?.askVcChangeToPickUpState(sender)
    }
    @IBAction func tapLessorCancelBtn(_ sender: UIButton) {
        changeStateDelegate?.askVcToCancelLessorOrder(orderID)
    }
    
    override func prepareForReuse() {
        enablePickUpBtn()
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
        bookedPhoto.layer.cornerRadius = 10
        pickUpButton.layer.cornerRadius = 10
        lessorCancelBtn.layer.cornerRadius = 10
    }
    
    func disablePickUpBtn() {
        pickUpButton.isEnabled = false
        pickUpButton.backgroundColor = .gray
    }
    
    func enablePickUpBtn() {
        pickUpButton.isEnabled = true
        pickUpButton.backgroundColor = UIColor.OutdoorTribeColor.btnEnableColor
    }
}
