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
    @IBAction func tapCallButton(_ sender: UIButton) {
        WebRTCClient.shared.offer { sdp in
            WebRTCClient.shared.send(sdp: sdp, to: "George")
        }
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
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.3
        
        photoImageView.layer.cornerRadius = 10
        photoImageView.clipsToBounds = true
    }
    
    func hideEstimateTimeLabel() {
        timeStackView.isHidden = true
    }
}
