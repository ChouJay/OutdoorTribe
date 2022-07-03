//
//  BookingStageTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit

protocol LessorChangeStateDelegate {
    func askVcChangeToPickUpState(_ sender: UIButton)
    func askVcToCancelLessorOrder(_ sender: UIButton)
}

class BookedForLessorTableViewCell: UITableViewCell {

    @IBOutlet weak var bookedPhoto: UIImageView!
    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var lessorCancelBtn: UIButton!
    
    var changeStateDelegate: LessorChangeStateDelegate?
    
    @IBAction func tapPickUpButton(_ sender: UIButton) {
        changeStateDelegate?.askVcChangeToPickUpState(sender)
    }
    @IBAction func tapLessorCancelBtn(_ sender: UIButton) {
//        changeStateDelegate?.askVcChangeToDeliverState(sender)
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
        pickUpButton.backgroundColor = UIColor(red: 146 / 250, green: 182 / 250, blue: 137 / 250, alpha: 1)
    }

}

// MARK: - pickUP delegate
