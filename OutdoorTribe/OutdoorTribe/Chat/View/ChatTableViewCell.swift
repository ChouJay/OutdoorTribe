//
//  ChatTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    
    @IBOutlet weak var rightTextBubble: UILabel!
    @IBOutlet weak var leftTextBubble: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        rightTextBubble.isHidden = false
        leftTextBubble.isHidden = false
    }

}
