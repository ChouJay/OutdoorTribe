//
//  ImageTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/15.
//

import UIKit

protocol UploadPhotoDelegate {
    func askToUploadPhoto()
    func askToDeletePhoto(indexPath: IndexPath)
}

class ImageTableViewCell: UITableViewCell {
    
    var uploadedPhoto = [UIImage]()
    var photoDelegate: UploadPhotoDelegate? {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Collection view dataSource
extension ImageTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + uploadedPhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageItem = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ImageCollectionViewCell",
            for: indexPath) as? ImageCollectionViewCell else { fatalError() }
        imageItem.deletePhotoDelegate = self
        imageItem.removeButton.isHidden = false
        imageItem.iamgeView.contentMode = .center
        imageItem.iamgeView.preferredSymbolConfiguration = .init(pointSize: 40, weight: .unspecified, scale: .large)
        imageItem.iamgeView.image = nil
        imageItem.gestureRecognizers?.removeAll()
        if indexPath.row == 0 {
            imageItem.iamgeView.backgroundColor = .lightGray
            imageItem.iamgeView.image = UIImage(systemName: "photo")
            imageItem.tintColor = .darkGray
            let tap = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
            imageItem.removeButton.isHidden = true
            imageItem.addGestureRecognizer(tap)
        } else {
            imageItem.iamgeView.image = uploadedPhoto[indexPath.row - 1]
            imageItem.iamgeView.preferredSymbolConfiguration = .unspecified
            imageItem.iamgeView.contentMode = .scaleAspectFill
        }
        imageItem.iamgeView.layer.cornerRadius = 10
        imageItem.iamgeView.clipsToBounds = true
        return imageItem
    }
}

// MARK: - collection view delegate
extension ImageTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

// MARK: - get photo delegate
extension ImageTableViewCell {
    @objc func choosePicture() {
        photoDelegate?.askToUploadPhoto()
    }
}

// MARK: - deletePhoto delegate
extension ImageTableViewCell: DeletePhotoDelegate {
    func askToDeletePhoto(cell: UICollectionViewCell) {
        guard let indexPath = imageCollectionView.indexPath(for: cell) else { return }
        photoDelegate?.askToDeletePhoto(indexPath: indexPath)
    }
}
