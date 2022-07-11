//
//  BookingPhotoTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class BookingPhotoTableViewCell: UITableViewCell {
    var galleryUrlStrings = [String]()
    var pageController = UIPageControl()
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        galleryCollectionView.collectionViewLayout = createCompositionalLayout()
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 0,
                                                    trailing: 0)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPaging
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
// layOut pageController func
    func layoutPageController() {
        pageController.addTarget(self, action: #selector(controlGallery(pageControl:)), for: .valueChanged)
        pageController.numberOfPages = galleryUrlStrings.count
        pageController.currentPage = 0
        pageController.backgroundStyle = .automatic
        contentView.addSubview(pageController)
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pageController.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func controlGallery(pageControl: UIPageControl) {
        let page = pageControl.currentPage
        galleryCollectionView.scrollToItem(
            at: IndexPath(item: page, section: 0),
            at: .centeredHorizontally,
            animated: true)
    }
}

// MARK: - Collection view dataSource
extension BookingPhotoTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        galleryUrlStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BookingPhotoCollectionViewCell",
            for: indexPath) as? BookingPhotoCollectionViewCell else { fatalError() }
        item.galleryView.image = nil
        guard let url = URL(string: galleryUrlStrings[indexPath.row]) else { return item }
        item.galleryView.kf.setImage(with: url)
        return item
    }
}

// MARK: - Collection view delegate
extension BookingPhotoTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        pageController.currentPage = indexPath.row
    }
}
