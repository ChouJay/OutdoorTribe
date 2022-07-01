//
//  UserInfoCollectionCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/30.
//

import UIKit

class UserInfoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func layoutPhotoImage() {
        photoImage.layer.cornerRadius = photoImage.frame.width / 2
    }
}
