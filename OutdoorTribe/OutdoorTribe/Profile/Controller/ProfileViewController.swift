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
    
    @IBOutlet weak var photoEditBtn: UIButton!
    @IBOutlet weak var userPhotoImage: UIImageView!
    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func tapLogOutBtn(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch {
            print(error)
        }
    }
    
    @IBAction func tapEditPhotoBtn(_ sender: Any) {
        askToUploadPhoto()
    }
    @IBOutlet var containViews: [UIView]!
    @IBAction func tapSegmentControl(_ sender: UISegmentedControl) {
        for containerView in containViews {
            containerView.isHidden = true
        }
        containViews[sender.selectedSegmentIndex].isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        
        userPhotoImage.layer.cornerRadius = 70
        userPhotoImage.layer.borderWidth = 5
        userPhotoImage.layer.borderColor = UIColor.gray.cgColor
        
        
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
            if let url = URL(string: account.photo) {
                self?.userPhotoImage.kf.setImage(with: url)
            }
        }
        // Do any additional setup after loading the view.
    }
}

// MARK: - uploade photo delegate
extension ProfileViewController: UploadPhotoDelegate {
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            userPhotoImage.image = image
            guard let userID = userInfo?.userID else { return }
            AccountManager.shared.uploadUserPhoto(uploadedImage: image, userID: userID)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
