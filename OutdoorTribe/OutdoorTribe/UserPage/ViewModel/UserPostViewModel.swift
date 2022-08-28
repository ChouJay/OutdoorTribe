//
//  ProductViewModel.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/8/24.
//

import Foundation

class UserPostViewModel {

    var bindedPostUrl: ObservableObject<[String]?> = ObservableObject(nil)
    
    func getUserPosts(posterUid: String) {
        var postUrls = [String]()
        AccountManager.shared.getUserPost(byUserID: posterUid) { [weak self] productsFromServer in
            for product in productsFromServer {
                postUrls.append(product.photoUrl[0])
            }
            self?.bindedPostUrl.value = postUrls
        }
    }
}
