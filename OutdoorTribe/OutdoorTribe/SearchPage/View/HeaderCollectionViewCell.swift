//
//  HeaderCollectionViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/22.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "\(HeaderCollectionViewCell.self)"

    var selectedState = false {
        didSet {
            if selectedState {
                selectedView.isHidden = false
                changeVectorImageColor(color: .white)
                titleLabel.textColor = .white
                
            } else {
                selectedView.isHidden = true
                changeVectorImageColor(color: .OutdoorTribeColor.mainColor)
                titleLabel.textColor = .OutdoorTribeColor.mainColor
            }
        }
    }
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!

    func layOutItem(by indexPath: IndexPath) {
        titleLabel.text = Classification.shared.differentOutdoorType[indexPath.row]
        iconImage.image = UIImage(named: Classification.shared.differentOutdoorType[indexPath.row])
        selectedView.layer.cornerRadius = 37
        changeVectorImageColor(color: .OutdoorTribeColor.mainColor)
        titleLabel.textColor = .OutdoorTribeColor.mainColor

//        if selectedState {
//            selectedView.isHidden = false
//            changeVectorImageColor(color: .white)
//            titleLabel.textColor = .white
//            
//        } else {
//            selectedView.isHidden = true
//            changeVectorImageColor(color: .OutdoorTribeColor.mainColor)
//            titleLabel.textColor = .OutdoorTribeColor.mainColor
//        }
    }
    
    func changeVectorImageColor(color: UIColor) {
        let templateImage = iconImage.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        iconImage.image = templateImage
        titleLabel.textColor = color
        tintColor = color
    }
}
