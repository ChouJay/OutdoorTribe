//
//  LeaseInTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit

class LeaseInTableViewCell: UITableViewCell {

    @IBOutlet weak var productPhoto: UIImageView!
    
    @IBOutlet weak var returnBtn: UIButton!
    
    @IBAction func tapReturnBtn(_ sender: Any) {
        
    }
    
    override func prepareForReuse() {
        enableReturnBtn()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
