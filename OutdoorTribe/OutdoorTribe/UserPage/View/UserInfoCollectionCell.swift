//
//  UserInfoCollectionCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/30.
//

import UIKit

protocol AskVCToReportUserDelegate {
    func askVcToReportUser()
}

class UserInfoCollectionCell: UICollectionViewCell {
    
    var reportDelegate: AskVCToReportUserDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var reportBtn: UIButton!
    
    @IBAction func tapReportBtn(_ sender: Any) {
        reportDelegate?.askVcToReportUser()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func layoutPhotoImage() {
        photoImage.layer.cornerRadius = photoImage.frame.width / 2
    }
    
    func prepareToShowData(infoViewModel: UserInfoViewModel, userID: String, posterUid: String, userPostCount: Int) {
        infoViewModel.updateData(currentUserID: userID, posterUid: posterUid, item: self, userPosetCount: userPostCount)

    }
}
