//
//  PhotoWallHeaderReusableView.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/30.
//

import UIKit

protocol FollowUserDelegate {
    func askVcFollowUser()
}

class PhotoWallHeaderReusableView: UICollectionReusableView {
    
    var delegate: FollowUserDelegate?
    
    @IBAction func tapFollowButton(_ sender: Any) {
        print("tset")
        delegate?.askVcFollowUser()
    }
}