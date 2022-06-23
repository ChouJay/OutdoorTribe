//
//  HeaderCollectionViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/22.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "\(HeaderCollectionViewCell.self)"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func layOutItem(by indexPath: IndexPath) {
        titleLabel.text = Classification.shared.differentOutdoorType[indexPath.row]
    }
}
