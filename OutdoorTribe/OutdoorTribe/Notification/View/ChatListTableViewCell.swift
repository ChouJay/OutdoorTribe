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
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastSendTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutPhoto()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func layoutPhoto() {
        chatListPhoto.layer.cornerRadius = chatListPhoto.frame.height / 2
        chatListPhoto.contentMode = .scaleAspectFill
    }

}
