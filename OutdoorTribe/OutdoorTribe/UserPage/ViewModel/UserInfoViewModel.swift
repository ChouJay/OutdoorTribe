//
//  UserInfoViewModel.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/8/24.
//

import Foundation
import Kingfisher

class UserInfoViewModel {
    var bindedUserAccount: ObservableObject<Account?> = ObservableObject(nil)
    
    var score = 0.0
    var totalScore = 0.0

    var scoreString = 0
    var nameString = ""
    var followerCountString = 0
    var postCountString = 0
    var ratingCountString = 0
    
    func updateData(currentUserID: String, posterUid: String, item: UserInfoCollectionCell, userPosetCount: Int) {
        guard let userAccount = bindedUserAccount.value else { return }

        totalScore = userAccount.totalScore
        if currentUserID == posterUid {
            item.reportBtn.isHidden = true
        }
        if userAccount.ratingCount != 0 {
            score = totalScore / userAccount.ratingCount
        }
        
        item.scoreLabel.text = String(format: "%.1f", score)
        item.nameLabel.text = userAccount.name
        item.followerCountLabel.text = String(userAccount.followerCount)
        item.postCountLabel.text = String(userPosetCount)
        item.ratingCountLabel.text = "(\(String(Int(userAccount.ratingCount))))"
        if userAccount.photo != "" {
            guard let url = URL(string: userAccount.photo) else { return }
            item.photoImage.kf.setImage(with: url)
        }
    }
    
    func addFollowerToVM(to currentUserID: String) {
        guard var userAccount = bindedUserAccount.value else { return }
        userAccount.followerCount += 1
        bindedUserAccount.value = userAccount
        SubscribeManager.shared.followUser(currentUserID: currentUserID, otherUser: userAccount)
    }
    
    func addBlockUerToVM(to currentUserID: String) {
        guard let userAccount = bindedUserAccount.value else { return }
        AccountManager.shared.blockUser(byUserID: currentUserID, blockUser: userAccount)
    }
}
