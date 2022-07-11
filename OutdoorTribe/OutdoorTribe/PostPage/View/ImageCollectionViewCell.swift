//
//  ImageCollectionViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/15.
//

import UIKit

protocol DeletePhotoDelegate {
    func askToDeletePhoto(cell: UICollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    var deletePhotoDelegate: DeletePhotoDelegate?
    
    @IBOutlet weak var iamgeView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    @IBAction func tapRemoveBtn(_ sender: Any) {
        deletePhotoDelegate?.askToDeletePhoto(cell: self)
    }
}
