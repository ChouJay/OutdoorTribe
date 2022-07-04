//
//  EditPostViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/4.
//

import UIKit
import FirebaseAuth
import Kingfisher

class EditPostViewController: UIViewController {
    let firebaseAuth = Auth.auth()
    var myAccount: Account?
    var allUserProducts = [Product]()
    
    @IBOutlet weak var editCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editCollectionView.register(
            UINib(nibName: "PhotoWallHeaderReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "photoWall")
        editCollectionView.collectionViewLayout = createCompositionalLayout()
        editCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUserUid = firebaseAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserPost(byUserID: currentUserUid) { [weak self] productsFromServer in
            self?.allUserProducts = productsFromServer
            self?.editCollectionView.reloadData()
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(230))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .none
                
                return section
            case 1:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/3),
                    heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 3)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1/3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 3
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 0)
                section.orthogonalScrollingBehavior = .none
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(0))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)
                header.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [header]
                return section
                
            default:
                fatalError()
            }
        }
    }
}

// MARK: - collection view dataSource
extension EditPostViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return allUserProducts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let item = collectionView.dequeueReusableCell(
                withReuseIdentifier: "EditInfoCollectionViewCell",
                for: indexPath) as? EditInfoCollectionViewCell else { fatalError() }
            guard let myAccount = myAccount else { return item }
            let totalScore = myAccount.totalScore
            var score = 0.0
            if myAccount.ratingCount != 0 {
                score = totalScore / myAccount.ratingCount
            }
            item.scoreLabel.text = String(score)
            item.nameLabel.text = myAccount.name
            item.followerCountLabel.text = String(myAccount.followerCount)
            item.postCountLabel.text = String(allUserProducts.count)
            item.ratingCountLabel.text = "(\(String(Int(myAccount.ratingCount))))"
            item.layoutPhotoImage()
            if myAccount.photo != "" {
                guard let url = URL(string: myAccount.photo) else { return item }
                item.photoImage.kf.setImage(with: url)
            }
            
            return item
        } else {
            guard let item = collectionView.dequeueReusableCell(
                withReuseIdentifier: "EditPostCollectionViewCell",
                for: indexPath) as? EditPostCollectionViewCell else { fatalError() }
            guard let urlString = allUserProducts[indexPath.row].photoUrl.first else { return item}
            let url = URL(string: urlString)
            item.postImage.kf.setImage(with: url)
            return item

        }
    }
}
