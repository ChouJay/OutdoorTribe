//
//  RenterTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit

class RenterTableViewCell: UITableViewCell {

    @IBOutlet weak var renterPhoroImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func photoLayOut() {
        renterPhoroImage.layer.cornerRadius = 30
    }
}
