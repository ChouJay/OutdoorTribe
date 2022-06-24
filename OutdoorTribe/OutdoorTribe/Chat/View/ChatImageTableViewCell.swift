//
//  ImageTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/24.
//

import UIKit

class ChatImageTableViewCell: UITableViewCell {

    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
