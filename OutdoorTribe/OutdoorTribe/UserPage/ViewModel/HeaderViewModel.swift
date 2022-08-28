//
//  HeaderViewModel.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/8/25.
//

import Foundation

class HeaderViewModel {
    var bindedUserInfos: ObservableObject<[Account]?> = ObservableObject(nil)
    
    func getAllUserInfos(currentUserID: String) {
        SubscribeManager.shared.loadingSubscriber(currentUserID: currentUserID) { [weak self] accountsFromServer in
            self?.bindedUserInfos.value = accountsFromServer
        }
    }
    
    func judgeHeaderBtnStatus(targetView headerView: PhotoWallHeaderReusableView,
                              userID currentUserID: String,
                              whoPost posterUid: String,
                              search allAccounts: [Account],
                              ifExist userAccount: Account) {
        if currentUserID == "" {
            headerView.blockBtn.isEnabled = false
            headerView.followBtn.isEnabled = false
            headerView.blockBtn.alpha = 0.5
            headerView.followBtn.alpha = 0.5
        } else {
            if currentUserID == posterUid {
                headerView.blockBtn.isEnabled = false
                headerView.followBtn.isEnabled = false
                headerView.blockBtn.alpha = 0.5
                headerView.followBtn.alpha = 0.5
            } else {
                headerView.followBtn.isEnabled = true
                headerView.followBtn.alpha = 1
                
                for account in allAccounts where account.userID == userAccount.userID {
                    headerView.followBtn.isEnabled = false
                    headerView.followBtn.alpha = 0.5
                }
                
                headerView.blockBtn.isEnabled = true
                headerView.blockBtn.alpha = 1
            }
        }
    }
}
