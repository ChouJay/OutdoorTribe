//
//  UserViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit
import FirebaseAuth

class UserViewController: UIViewController {

    var posterUid = ""
    var othersAccount: Account?
    var allUserProducts = [Product]()
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var postCountLabel: UILabel!
    
    @IBAction func tapFollowBtn(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        guard let currentUser = firebaseAuth.currentUser,
              let orthersAccount = othersAccount else { return }
        SubscribeManager.shared.followUser(currentUserID: currentUser.uid, otherUser: orthersAccount)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productCollectionView.collectionViewLayout = createCompositionalLayout()
        productCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AccountManager.shared.getUserInfo(by: posterUid) { [weak self] accountFromServer in
            self?.othersAccount = accountFromServer
            let totalScore = accountFromServer.totalScore
            var score = 0.0
            if accountFromServer.ratingCount != 0 {
                score = totalScore / accountFromServer.ratingCount
            }
            self?.scoreLabel.text = String(score)
            self?.followerCountLabel.text = String(accountFromServer.followerCount)
            self?.userNameLabel.text = accountFromServer.name
        }
        
        AccountManager.shared.getUserPost(byUserID: posterUid) { [weak self] productsFromServer in
            self?.allUserProducts = productsFromServer
            self?.postCountLabel.text = String(productsFromServer.count)
            self?.productCollectionView.reloadData()
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
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
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - collection view dataSource
extension UserViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPostCollectionCell", for: indexPath) as? UserPostCollectionCell else { fatalError() }
        return item
    }
    
}
