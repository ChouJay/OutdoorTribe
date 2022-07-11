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
    var currentUserID = ""
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firebaseAuth = Auth.auth()
        guard let userID = firebaseAuth.currentUser?.uid else { return }
        currentUserID = userID
        
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
            item.scoreLabel.text = String(format: "%.1f", score)
            item.nameLabel.text = othersAccount.name
            item.followerCountLabel.text = String(othersAccount.followerCount)
            item.postCountLabel.text = String(allUserProducts.count)
            item.ratingCountLabel.text = "(\(String(Int(othersAccount.ratingCount))))"
            item.layoutPhotoImage()
            if othersAccount.photo != "" {
                guard let url = URL(string: othersAccount.photo) else { return item }
                item.photoImage.kf.setImage(with: url)
            }
            
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
        if currentUserID == posterUid {
            headerView.blockBtn.isEnabled = false
            headerView.followBtn.isEnabled = false
            headerView.blockBtn.alpha = 0.5
            headerView.followBtn.alpha = 0.5
        } else {
            headerView.blockBtn.isEnabled = true
            headerView.followBtn.isEnabled = true
            headerView.blockBtn.alpha = 1
            headerView.followBtn.alpha = 1
        }
        headerView.delegate = self
        headerView.followBtn.layer.cornerRadius = 5
        headerView.blockBtn.layer.cornerRadius = 5
        headerView.blockBtn.layer.borderWidth = 1
        headerView.blockBtn.layer.borderColor = UIColor.lightGray.cgColor
        return headerView
    }
}

// MARK: - collection view delegate
extension UserViewController: UICollectionViewDelegate {
}

// MARK: - follow user delegate
extension UserViewController: userInteractDelegate {
    func askVcBlockUser() {
        guard let otherAccount = othersAccount else { return }

        AccountManager.shared.blockUser(byUserID: currentUserID, blockUser: otherAccount)
    }
    
    func askVcFollowUser() {
        guard var othersAccount = othersAccount else { return }
        othersAccount.followerCount += 1
        SubscribeManager.shared.followUser(currentUserID: currentUserID, otherUser: othersAccount)
    }
}
