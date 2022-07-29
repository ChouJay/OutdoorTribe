//
//  ApplyTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Kingfisher

class ApplyTableViewCell: UITableViewCell {
    
    var noApplicationLabel: UILabel = {
        let label = UILabel()
        label.text = "There is no application!"
        label.textColor = .lightGray
        label.font = UIFont(name: "Arial Bold", size: 24)
        return label
    }()
    
    var applyingOrders = [Order]() {
        didSet {
            applyCollectionView.reloadData()
        }
    }
    @IBOutlet weak var applyCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyCollectionView.dataSource = self
        applyCollectionView.delegate = self
        showHintLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showHintLabel() {
        contentView.addSubview(noApplicationLabel)
        noApplicationLabel.center(inView: contentView)
    }
}

// MARK: - collection view dataSource
extension ApplyTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if applyingOrders.count == 0 {
            noApplicationLabel.isHidden = false
        } else {
            noApplicationLabel.isHidden = true
        }
        return applyingOrders.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ApplyCollectionViewCell",
            for: indexPath) as? ApplyCollectionViewCell else { fatalError() }
        guard let product = applyingOrders[indexPath.row].product else { return item }
        let urlStringArray = product.photoUrl
        let titleString = product.title
        item.applicationNameLabel.text = titleString
        item.notifiedPhoto.kf.setImage(with: URL(string: urlStringArray.first!))
        item.setupPhotoLayout()
        return item
    }
}

// MARK: - collection view delegate
extension ApplyTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
