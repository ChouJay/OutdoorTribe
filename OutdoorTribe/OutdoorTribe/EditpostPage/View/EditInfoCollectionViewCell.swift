//
//  EditInfoCollectionViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/4.
//

import UIKit

class EditInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    
    func layoutPhotoImage() {
        photoImage.layer.cornerRadius = photoImage.frame.width / 2
    }
}
