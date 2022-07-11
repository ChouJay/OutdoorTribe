//
//  ChatTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var rightBubbleView: UIView!
    @IBOutlet weak var leftBubbleView: UIView!
    @IBOutlet weak var rightTextBubble: UILabel!
    @IBOutlet weak var leftTextBubble: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        rightBubbleView.isHidden = false
        leftBubbleView.isHidden = false
    }
    
    func layOutTextBubble() {
        photoView.layer.cornerRadius = photoView.frame.width / 2
        rightBubbleView.layer.cornerRadius = 10
        leftBubbleView.layer.cornerRadius = 10
    }

}
