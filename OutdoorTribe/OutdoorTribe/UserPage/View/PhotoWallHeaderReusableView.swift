//
//  PhotoWallHeaderReusableView.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/30.
//

import UIKit

protocol userInteractDelegate {
    func askVcFollowUser()
    func askVcBlockUser()
}

class PhotoWallHeaderReusableView: UICollectionReusableView {
    
    var delegate: userInteractDelegate?
    
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBAction func tapFollowButton(_ sender: Any) {
        print("tset")
        delegate?.askVcFollowUser()
        followBtn.isEnabled = false
        followBtn.alpha = 0.7
    }
    @IBAction func tapBlockBtn(_ sender: Any) {
        delegate?.askVcBlockUser()
    }
    
}
