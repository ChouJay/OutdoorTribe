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
    let firebaseAuth = Auth.auth()
    var posterUid = ""
    var othersAccount: Account?
    var currentUserID = ""
    
    private var userPostViewModel = UserPostViewModel()
    private var headerViewModel = HeaderViewModel()
    var userInfoViewModel = UserInfoViewModel()
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUserPostBinder()
        setupHeaderBinder()
        setupUserAccountBinder()
        
        productCollectionView.register(
            UINib(nibName: "PhotoWallHeaderReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "photoWall")
        productCollectionView.collectionViewLayout = createCompositionalLayout()
        productCollectionView.dataSource = self
        
        guard let userID = firebaseAuth.currentUser?.uid else { return }
        currentUserID = userID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userPostViewModel.getUserPosts(posterUid: posterUid)
        
        if firebaseAuth.currentUser?.uid != nil {
            headerViewModel.getAllUserInfos(currentUserID: currentUserID)
        }
    }
    
    private func setupUserPostBinder() {
        userPostViewModel.bindedPostUrl.bind { [weak self] postUrls in
            if postUrls != nil {
                self?.productCollectionView.reloadData()
            }
        }
    }
    
    private func setupHeaderBinder() {
        headerViewModel.bindedUserInfos.bind { [weak self] userInfo in
            if userInfo != nil {
                self?.productCollectionView.reloadData()
            }
        }
    }

    private func setupUserAccountBinder() {
        userInfoViewModel.bindedUserAccount.bind { [weak self] account in
            if account != nil {
                self?.productCollectionView.reloadSections(IndexSet(integer: 0))
            }
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
            return userPostViewModel.bindedPostUrl.value?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let item = collectionView.dequeueReusableCell(
                withReuseIdentifier: "UserInfoCollectionCell",
                for: indexPath) as? UserInfoCollectionCell else { fatalError() }
            let userPostCount = userPostViewModel.bindedPostUrl.value?.count ?? 0
            item.prepareToShowData(infoViewModel: userInfoViewModel,
                                   userID: currentUserID,
                                   posterUid: posterUid,
                                   userPostCount: userPostCount)
            item.reportDelegate = self
            item.layoutPhotoImage()
            return item
        } else {
            guard let item = collectionView.dequeueReusableCell(
                withReuseIdentifier: "UserPostCollectionCell",
                for: indexPath) as? UserPostCollectionCell else { fatalError() }
            guard let urlString = userPostViewModel.bindedPostUrl.value?[indexPath.row] else { return item }
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
        headerView.followBtn.layer.cornerRadius = 5
        headerView.blockBtn.layer.cornerRadius = 5
        headerView.blockBtn.layer.borderWidth = 1
        headerView.blockBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        guard let userAccount = userInfoViewModel.bindedUserAccount.value,
              let allAccounts = headerViewModel.bindedUserInfos.value else { return headerView }
        headerViewModel.judgeHeaderBtnStatus(targetView: headerView,
                                             userID: currentUserID,
                                             whoPost: posterUid,
                                             search: allAccounts,
                                             ifExist: userAccount)
        return headerView
    }
}

// MARK: - collection view delegate
extension UserViewController: UICollectionViewDelegate {
}

// MARK: - follow user delegate
extension UserViewController: userInteractDelegate {
    func askVcBlockUser() {
        userInfoViewModel.addBlockUerToVM(to: currentUserID)
    }
    
    func askVcFollowUser() {
        userInfoViewModel.addFollowerToVM(to: currentUserID)
    }
}

// MARK: - report delegate
extension UserViewController: AskVCToReportUserDelegate {
    func askVcToReportUser() {
        let alertController = UIAlertController(title: "Do you want to report this user?",
                                                message: "Please enter the reason",
                                                preferredStyle: .alert)
        alertController.addTextField { _ in
    
        }
          
        let defaultAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let alertRepotAction = UIAlertAction(title: "Report!", style: .destructive) { _ in
            guard let reportReason = alertController.textFields?.first?.text else { return }
            print(reportReason)
            
        }

        alertController.addAction(defaultAction)
        alertController.addAction(alertRepotAction)
        present(alertController, animated: true, completion: nil)
    }
}
