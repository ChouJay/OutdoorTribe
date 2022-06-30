//
//  MapCollectionViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit

protocol MapRouteDelegate {
    func showRoute(sender: MapCollectionViewCell)
}

class MapCollectionViewCell: UICollectionViewCell {
    
    var routeDelegae: MapRouteDelegate?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var renterNameLabel: UILabel!
    
    @IBAction func tapRouteButton(_ sender: UIButton) {
        routeDelegae?.showRoute(sender: self)
    }
    
    override func prepareForReuse() {
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        layOutMapCell()
    }
      
    func layOutMapCell() {
        self.layer.cornerRadius = 10
        photoImageView.layer.cornerRadius = 10
        photoImageView.clipsToBounds = true
    }
    
    func hideEstimateTimeLabel() {
        timeStackView.isHidden = true
    }
}
