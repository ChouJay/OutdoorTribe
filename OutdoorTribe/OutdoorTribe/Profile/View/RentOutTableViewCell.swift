//
//  RentOutTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit

class RentOutTableViewCell: UITableViewCell {

    @IBOutlet weak var productPhoto: UIImageView!
    
    @IBOutlet weak var finishBtn: UIButton!
    
    @IBAction func tapFinishBtn(_ sender: Any) {
        
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
    }

    func enableFinishBtn() {
        finishBtn.isEnabled = true
        finishBtn.backgroundColor = UIColor(red: 146 / 250, green: 182 / 250, blue: 137 / 250, alpha: 1)
    }
    
    func disableFinishBtn() {
        finishBtn.isEnabled = false
        finishBtn.backgroundColor = .gray
    }

}
