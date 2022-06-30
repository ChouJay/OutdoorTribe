//
//  UserViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit
import FirebaseAuth
import Kingfisher

class UserViewController: UIViewController {

    var posterUid = ""
    var othersAccount: Account?
    var allUserProducts = [Product]()
    

    @IBOutlet weak var productCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productCollectionView.register(
            UINib(nibName: "PhotoWallHeaderReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "photoWall")
        productCollectionView.collectionViewLayout = createCompositionalLayout()
        productCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AccountManager.shared.getUserPost(byUserID: posterUid) { [weak self] productsFromServer in
            self?.allUserProducts = productsFromServer
            self?.productCollectionView.reloadData()
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
                    heightDimension: .absolute(50))
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
        
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1/3),
//            heightDimension: .fractionalHeight(1))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 3)
//
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1),
//            heightDimension: .fractionalWidth(1/3))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 3
//        section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 0)
//        section.orthogonalScrollingBehavior = .none
//
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
    }
}

// MARK: - collection view dataSource
extension UserViewController: UICollectionViewDataSource {
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
                withReuseIdentifier: "UserInfoCollectionCell",
                for: indexPath) as? UserInfoCollectionCell else { fatalError() }
            guard let othersAccount = othersAccount else { return item }
            let totalScore = othersAccount.totalScore
            var score = 0.0
            if othersAccount.ratingCount != 0 {
                score = totalScore / othersAccount.ratingCount
            }
            item.scoreLabel.text = String(score)
            item.nameLabel.text = othersAccount.name
            item.followerCountLabel.text = String(othersAccount.followerCount)
            item.postCountLabel.text = String(allUserProducts.count)
            item.ratingCountLabel.text = "(\(String(Int(othersAccount.ratingCount))))"
            return item
        } else {
            guard let item = collectionView.dequeueReusableCell(
                withReuseIdentifier: "UserPostCollectionCell",
                for: indexPath) as? UserPostCollectionCell else { fatalError() }
            guard let urlString = allUserProducts[indexPath.row].photoUrl.first else { return item}
            let url = URL(string: urlString)
            item.postImage.kf.setImage(with: url)
            return item

        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "photoWall",
            for: indexPath) as? PhotoWallHeaderReusableView else { fatalError() }
        headerView.delegate = self
        return headerView
    }
}

// MARK: - follow user delegate
extension UserViewController: FollowUserDelegate {
    func askVcFollowUser() {
        let firebaseAuth = Auth.auth()
        guard let currentUser = firebaseAuth.currentUser,
              let orthersAccount = othersAccount else { return }
        SubscribeManager.shared.followUser(currentUserID: currentUser.uid, otherUser: orthersAccount)
    }
}
