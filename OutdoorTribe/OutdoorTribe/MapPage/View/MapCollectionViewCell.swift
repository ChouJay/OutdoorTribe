//
//  MapCollectionViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit

protocol MapRouteDelegate {
    func showRoute(sender: UIButton)
}

class MapCollectionViewCell: UICollectionViewCell {
    
    var routeDelegae: MapRouteDelegate?
    
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    @IBAction func tapRouteButton(_ sender: UIButton) {
        routeDelegae?.showRoute(sender: sender)
    }
}
