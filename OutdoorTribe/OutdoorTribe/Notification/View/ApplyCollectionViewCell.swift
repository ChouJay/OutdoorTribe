//
//  ApplyCollectionViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit

class ApplyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var notifiedPhoto: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupPhotoLayout() {
        notifiedPhoto.layer.cornerRadius = notifiedPhoto.frame.width / 2
    }
}
