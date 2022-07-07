//
//  BlockTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/7.
//

import UIKit

class BlockTableViewCell: UITableViewCell {

    
    @IBOutlet weak var blockPhotoView: UIImageView!
    @IBOutlet weak var blockNameLabel: UILabel!
    @IBOutlet weak var removeBlockBtn: UIButton!
    @IBAction func tapRemoveBlockBtn(_ sender: Any) {
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layoutButton() {
        removeBlockBtn.layer.cornerRadius = 10
    }

}
