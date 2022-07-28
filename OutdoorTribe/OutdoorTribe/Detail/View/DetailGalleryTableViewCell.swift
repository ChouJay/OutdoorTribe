//
//  DetailGalleryTableViewCell.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import UIKit
import Kingfisher

class DetailGalleryTableViewCell: UITableViewCell {
    var imageUrlStings = [String]()
    var pageController = UIPageControl()
    var chooseProduct: Product?
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        galleryCollectionView.collectionViewLayout = createCompositionalLayout()
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
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
    func layoutPageController(chooseProduct: Product) {
        contentView.addSubview(pageController)
        pageController.addTarget(self, action: #selector(controlGallery(pageControl:)), for: .valueChanged)
        pageController.numberOfPages = chooseProduct.photoUrl.count
        pageController.currentPage = 0
        pageController.backgroundStyle = .automatic
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
    
    func showGallery() {
        guard let urlStrings = chooseProduct?.photoUrl,
              let chooseProduct = chooseProduct else { return }
        imageUrlStings = urlStrings
        layoutPageController(chooseProduct: chooseProduct)
    }
}

// MARK: - collection view dataSource
extension DetailGalleryTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageUrlStings.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GalleryCollectionViewCell",
            for: indexPath) as? GalleryCollectionViewCell else { fatalError() }
        item.galleryView.image = nil
        guard let url = URL(string: imageUrlStings[indexPath.row]) else { return item }
        item.galleryView.kf.setImage(with: url)
        return item
    }
}

// MARK: - collection view delegate
extension DetailGalleryTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        pageController.currentPage = indexPath.row
    }
}
