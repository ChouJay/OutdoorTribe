//
//  BlockTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/7.
//

import UIKit

protocol RemoveBlockDelegate {
    func askToRemoveBlock(tapedCell: UITableViewCell)
}

class BlockTableViewCell: UITableViewCell {

    var removeBlockDelegate: RemoveBlockDelegate?
    
    @IBOutlet weak var blockPhotoView: UIImageView!
    @IBOutlet weak var blockNameLabel: UILabel!
    @IBOutlet weak var removeBlockBtn: UIButton!
    @IBAction func tapRemoveBlockBtn(_ sender: Any) {
        removeBlockDelegate?.askToRemoveBlock(tapedCell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutButton()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layoutButton() {
        removeBlockBtn.layer.cornerRadius = 10
        blockPhotoView.layer.cornerRadius = blockPhotoView.frame.size.height / 2
    }

}
