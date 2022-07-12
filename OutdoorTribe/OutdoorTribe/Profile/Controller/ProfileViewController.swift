//
//  ProfileViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController {
    let firestoreAuth = Auth.auth()
    let imagePickerController = UIImagePickerController()
    var userInfo: Account?
    var subscribers = [Account]()
    var allUserProducts = [Product]()
    
    @IBOutlet weak var photoEditBtn: UIButton!
    @IBOutlet weak var userPhotoImage: UIImageView!
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var subscriCountLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet var containViews: [UIView]!
        
    @IBAction func tapEditPhotoBtn(_ sender: Any) {
        askToUploadPhoto()
    }
    @IBAction func tapSegmentControl(_ sender: UISegmentedControl) {
        for containerView in containViews {
            containerView.isHidden = true
        }
        containViews[sender.selectedSegmentIndex].isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPullMenuBtn()
        
        imagePickerController.delegate = self
        
        userPhotoImage.layer.cornerRadius = 70
        userPhotoImage.layer.borderWidth = 5
        userPhotoImage.layer.borderColor = UIColor.gray.cgColor
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
            if let url = URL(string: account.photo) {
                self?.userPhotoImage.kf.setImage(with: url)
            }
            let totalScore = account.totalScore
            var score = 0.0
            if account.ratingCount != 0 {
                score = totalScore / account.ratingCount
            }
            let ratingCount = Int(account.ratingCount)
            self?.ratingCountLabel.text = String(format: "%.1f", score) + "(\(String(ratingCount)))"
        }
        AccountManager.shared.getUserPost(byUserID: uid) { [weak self] productsFromServer in
            self?.allUserProducts = productsFromServer
            guard let postCount = self?.allUserProducts.count else { return }
            self?.postCountLabel.text = String(postCount)
        }
        
        SubscribeManager.shared.loadingSubscriber(currentUserID: uid) { [weak self] accountsFromServer in
            self?.subscribers = accountsFromServer
            guard let subscribeCount = self?.subscribers.count else { return }
            self?.subscriCountLabel.text = String(subscribeCount)
        }
    }
    
    func setUpPullMenuBtn() {
//        menuBtn.showsMenuAsPrimaryAction = true
        menuBtn.menu = UIMenu(children: [
            UIAction(title: "Logout", handler: { [weak self] _ in
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch {
                    print(error)
                }
                
                self?.tabBarController?.selectedIndex = 0
        }),
            UIAction(title: "Block list", handler: { [weak self] _ in
                guard let childVC = self?.storyboard?.instantiateViewController(
                    withIdentifier: "BlockViewController") as? BlockViewController else { return }
                childVC.userInfo = self?.userInfo
                self?.navigationController?.pushViewController(childVC, animated: true)
        }),
            UIAction(title: "Privacy policy", handler: { [weak self] _ in
                let controller = WebView()
                controller.url = "https://www.privacypolicies.com/live/87961b7a-bce1-4d58-b679-0517b6dec594"
                self?.present(controller, animated: true)
        }),
            UIAction(title: "Delete account", handler: { _ in
                let firebaseAuth = Auth.auth()
                guard let currentUserID = firebaseAuth.currentUser?.uid else { return }
                firebaseAuth.currentUser?.delete(completion: { err in
                    if err == nil {
                        AccountManager.shared.deleteUserAccount(userID: currentUserID)
                        SubscribeManager.shared.deleteOthersSubscriptionWithUser(userID: currentUserID)
                        ProductManager.shared.deleteProductWithUser(userID: currentUserID)
                        OrderManger.shared.deleteOrderByUser(userID: currentUserID)
                        ChatManager.shared.deleteChatRoomByUser(userID: currentUserID)
                    } else {
                        print(err)
                    }
                })
        })
        ])
    }
}



// MARK: - uploade photo delegate
extension ProfileViewController: UploadPhotoDelegate {
    func askToDeletePhoto(indexPath: IndexPath) {
        // no use
    }
    
    func askToUploadPhoto() {
        let controller = UIAlertController(title: "請上傳照片", message: nil, preferredStyle: .actionSheet)
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let titleString = NSAttributedString(string: "Please upload some photo or video", attributes: titleAttributes)
        controller.setValue(titleString, forKey: "attributedTitle")
        controller.view.tintColor = UIColor.gray
        // 相機
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.takePicture()
        }
        controller.addAction(cameraAction)

        // 圖庫
        let photoLibraryAction = UIAlertAction(title: "Photolibrary", style: .default) { _ in
            self.openPhotoLibrary()
        }
        controller.addAction(photoLibraryAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancelAction)

        self.present(controller, animated: true, completion: nil)
    }
    /// 開啟相機
    func takePicture() {
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true)
    }
    /// 開啟圖庫
    func openPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
        self.present(imagePickerController, animated: true)
    }
    
}

// MARK: - ImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            userPhotoImage.image = image
            guard let userID = userInfo?.userID else { return }
            AccountManager.shared.uploadUserPhoto(uploadedImage: image, userID: userID)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - prepare for segue
extension ProfileViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SubscribeViewController {
            destinationVC.subscribers = subscribers
            
        } else {
            guard let destinationVC = segue.destination as? EditPostViewController else { return }
            destinationVC.myAccount = userInfo
            destinationVC.allUserProducts = allUserProducts
        }
    }
}
