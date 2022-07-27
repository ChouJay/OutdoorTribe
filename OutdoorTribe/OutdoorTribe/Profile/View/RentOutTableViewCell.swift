//
//  RentOutTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit

protocol RentOutCallDelegate {
    func askVcToCall(cell: UITableViewCell)
}

protocol FinishOrderDelegate {
    func askVcFinishOrder(cell: RentOutTableViewCell)
}

class RentOutTableViewCell: UITableViewCell {

    var finishOrderDelegate: FinishOrderDelegate?
    var callDelegate: RentOutCallDelegate?
    
    @IBOutlet weak var rentOutCallBtn: UIButton!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPhoto: UIImageView!
    
    @IBOutlet weak var returnDateLabel: UILabel!
    @IBOutlet weak var finishBtn: UIButton!
    
    @IBAction func tapFinishBtn(_ sender: Any) {
        finishOrderDelegate?.askVcFinishOrder(cell: self)
    }
    
    @IBAction func tapCallBtn(_ sender: Any) {
        callDelegate?.askVcToCall(cell: self)
    }
    
    override func prepareForReuse() {
        enableFinishBtn()
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
        productPhoto.layer.cornerRadius = 10
        finishBtn.layer.cornerRadius = 10
        rentOutCallBtn.layer.cornerRadius = 10
        rentOutCallBtn.layer.borderWidth = 1
        rentOutCallBtn.layer.borderColor = UIColor.darkGray.cgColor
    }

    func enableFinishBtn() {
        finishBtn.isEnabled = true
        finishBtn.backgroundColor = UIColor.OutdoorTribeColor.btnEnableColor
    }
    
    func disableFinishBtn() {
        finishBtn.isEnabled = false
        finishBtn.backgroundColor = .gray
    }

}
