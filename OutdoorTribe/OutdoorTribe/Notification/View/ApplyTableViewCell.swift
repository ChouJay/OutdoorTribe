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

    var orderDocumentsFromFirestore = [QueryDocumentSnapshot]() {
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - collection view dataSource
extension ApplyTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        orderDocumentsFromFirestore.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ApplyCollectionViewCell",
            for: indexPath) as? ApplyCollectionViewCell else { fatalError() }
        guard let product = orderDocumentsFromFirestore[indexPath.row].data()["product"] as? [String: Any] else { return item }
        print(product)
        guard let urlStringArray = product["photoUrl"] as? [String] else { return item}
        
        item.notifiedPhoto.kf.setImage(with: URL(string: urlStringArray.first!))
        item.setupPhotoLayout()
        return item
    }
}

// MARK: - collection view delegate
extension ApplyTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
