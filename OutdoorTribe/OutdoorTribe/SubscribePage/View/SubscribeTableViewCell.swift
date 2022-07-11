//
//  SubscribeTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit

protocol RemoveSubscriptionDelegate {
    func askToRecallSubscription(sender: UIButton)
}

class SubscribeTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    var removeSubscriptionDelegate: RemoveSubscriptionDelegate?
    
    @IBAction func tapRemove(_ sender: UIButton) {
        removeSubscriptionDelegate?.askToRecallSubscription(sender: sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layOutPhoto()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layOutPhoto() {
        photoImage.layer.cornerRadius = photoImage.frame.width / 2
        removeButton.layer.cornerRadius = 5
    }

}
