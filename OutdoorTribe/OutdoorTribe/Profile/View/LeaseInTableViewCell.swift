//
//  LeaseInTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit

protocol LeaseInCallDelegate {
    func askVcToCall(cell: UITableViewCell)
}

protocol ReturnOrderDelegate {
    func askVcReturnOrder(cell: LeaseInTableViewCell)
}

class LeaseInTableViewCell: UITableViewCell {

    var callDelegate: LeaseInCallDelegate?
    var returnOrderDelegate: ReturnOrderDelegate?
    
    @IBOutlet weak var productPhoto: UIImageView!
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var returnDateLabel: UILabel!
    @IBOutlet weak var returnBtn: UIButton!
    
    @IBOutlet weak var leaseInCallBtn: UIButton!
    
    @IBAction func tapReturnBtn(_ sender: Any) {
        returnOrderDelegate?.askVcReturnOrder(cell: self)
    }
    @IBAction func tapCallBtn(_ sender: Any) {
        callDelegate?.askVcToCall(cell: self)
    }
    
    override func prepareForReuse() {
        enableReturnBtn()
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
        returnBtn.layer.cornerRadius = 10
        leaseInCallBtn.layer.cornerRadius = 10
        leaseInCallBtn.layer.borderWidth = 1
        leaseInCallBtn.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func enableReturnBtn() {
        returnBtn.isEnabled = true
        returnBtn.backgroundColor = UIColor(red: 146 / 250, green: 182 / 250, blue: 137 / 250, alpha: 1)
    }
    
    func disableReturnBtn() {
        returnBtn.isEnabled = false
        returnBtn.backgroundColor = .gray
    }

}
