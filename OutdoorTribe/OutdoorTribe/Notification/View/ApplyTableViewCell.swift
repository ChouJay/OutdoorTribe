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
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "ApplyCollectionViewCell", for: indexPath) as? ApplyCollectionViewCell else { fatalError() }
        guard let product = orderDocumentsFromFirestore[indexPath.row].data()["product"] as? [String: Any] else { return item }
        print(product)
        guard let urlStringArray = product["photoUrl"] as? [String] else { return item}
        
//        let productInfo: Product?
//        var urlString = ""
//        do {
//            productInfo = try product.data(as: Product.self, decoder: Firestore.Decoder())
//            urlString = product?.photoUrl.first ?? ""
//        } catch {
//            print("decode failure: \(error)")
//        }
        item.notifiedPhoto.kf.setImage(with: URL(string: urlStringArray.first!))
        item.setupPhotoLayout()
        return item
    }
}
