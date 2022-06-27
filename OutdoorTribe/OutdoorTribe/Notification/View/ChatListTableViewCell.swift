//
//  ChatTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var chatListPhoto: UIImageView!
    @IBOutlet weak var chatListName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
