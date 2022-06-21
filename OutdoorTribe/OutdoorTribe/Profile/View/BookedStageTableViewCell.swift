//
//  BookingStageTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit

protocol ChangeStateDelegate {
    func askVcChangeToPickUpState(_ sender: UIButton)
    func askVcChangeToDeliverState(_ sender: UIButton)
}

class BookedStageTableViewCell: UITableViewCell {

    @IBOutlet weak var bookedPhoto: UIImageView!
    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var deliverButton: UIButton!
    
    var changeStateDelegate: ChangeStateDelegate?
    
    @IBAction func tapPickUpButton(_ sender: UIButton) {
        print("test")
        changeStateDelegate?.askVcChangeToPickUpState(sender)
    }
    @IBAction func tapDeliverButton(_ sender: UIButton) {
        changeStateDelegate?.askVcChangeToDeliverState(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK: - pickUP delegate
