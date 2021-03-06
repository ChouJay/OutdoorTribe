//
//  ViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/15.
//

import UIKit
import AVKit
import MapKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

protocol AskInfoCellDelegate {
    func askToDiscardInfo()
    func askToShowDateRange(dateRange: [Date])
}

class PostViewController: UIViewController {
  
    var userInfo: Account?
    let firestoreAuth = Auth.auth()
    var targetCell: ImageTableViewCell?
    var uploadedPhoto = [UIImage]()
    let imagePickerController = UIImagePickerController()
    var product = Product(renter: "Choujay",
                          renterUid: "",
                          title: "",
                          rent: 0,
                          address: GeoPoint(latitude: 0, longitude: 0),
                          addressString: "",
                          totalAmount: 0,
                          availableDate: [Date()],
                          description: "",
                          photoUrl: [],
                          classification: "")
    var startDate = Date()
    var endDate = Date()
    var avaliableTerm = [Date]()
    var toInfoCellDelegate: AskInfoCellDelegate?
    
    @IBOutlet weak var discardBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var postTableView: UITableView!
    @IBAction func tapPost(_ sender: Any) {
        product.renter = userInfo?.name ?? ""
        product.renterUid = userInfo?.userID ?? ""
        uploadPhoto()
        uploadedPhoto = []
        dismiss(animated: true)
        toInfoCellDelegate?.askToDiscardInfo()
        postTableView.reloadData()
    }
    
    @IBAction func tapDiscard(_ sender: Any) {
        uploadedPhoto = []
        toInfoCellDelegate?.askToDiscardInfo()
        postTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        postBtn.layer.cornerRadius = 10
        postBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        discardBtn.layer.cornerRadius = 10
        discardBtn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        postTableView.dataSource = self
        postTableView.delegate = self
        imagePickerController.delegate = self
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
        }
        // Do any additional setup after loading the view.
    }
    
    func convertAddressToGeoPoint(address: String) {
        let geoCorder = CLGeocoder()
        geoCorder.geocodeAddressString(address) { placemarks, error in
            if error != nil {
                print(error)
                return
            }
            guard let latitude = placemarks?.first?.location?.coordinate.latitude,
                  let longitude = placemarks?.first?.location?.coordinate.longitude else { return }
            print(latitude)
            print(longitude)
            self.product.address = GeoPoint(latitude: latitude, longitude: longitude)
        }
    }
    
    func uploadPhoto() {
        let group: DispatchGroup = DispatchGroup()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "images/\(UUID().uuidString).jpg"
        var endPoint = 0
        var paths = [String]()
        for image in uploadedPhoto {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            let fileRef = storageRef.child(path + String(endPoint))
            group.enter()
            fileRef.putData(imageData, metadata: nil) { storageMetadata, error in
                if error == nil && storageMetadata != nil {
                    fileRef.downloadURL { url, error in
                        guard let downloadUrl = url else {
                            print(error)
                            return
                        }
                        let urlString = downloadUrl.absoluteString
                        print(urlString)
                        paths.append(urlString)
                        group.leave()
                    }
                }
            }
            endPoint += 1
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard paths.isEmpty == false else { return }
            self?.product.photoUrl = paths
            print(self?.product.photoUrl)
            let firebaseAuth = Auth.auth()
            guard let product = self?.product,
                  let currentUser = firebaseAuth.currentUser else { return }
            ProductManager.shared.postProduct(withProduct: product)
            ProductManager.shared.postProductByUser(withProduct: product, user: currentUser)
        }
    }
}

// MARK: - post tableView dataSource
extension PostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ImageTableViewCell",
                for: indexPath) as? ImageTableViewCell else { fatalError() }
            cell.photoDelegate = self
            cell.uploadedPhoto = uploadedPhoto
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "InfoTableViewCell",
                for: indexPath) as? InfoTableViewCell else { fatalError() }
            toInfoCellDelegate = cell
            cell.descriptionTextView.delegate = self
            cell.titleTextField.delegate = self
            cell.addressTextField.delegate = self
            cell.passDateDelegate = self
            cell.classificationTextField.delegate = self
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ImageTableViewCell",
                for: indexPath) as? ImageTableViewCell else { fatalError() }
            return cell
        }
    }
}

// MARK: - post tableView delegate
extension PostViewController: UITableViewDelegate {
}

// MARK: - uploade photo delegate
extension PostViewController: UploadPhotoDelegate {
    func askToDeletePhoto(indexPath: IndexPath) {
        uploadedPhoto.remove(at: indexPath.row - 1)
        postTableView.reloadData()
    }

    func askToUploadPhoto() {
        let controller = UIAlertController(title: "???????????????", message: nil, preferredStyle: .actionSheet)
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let titleString = NSAttributedString(string: "Please upload some photo or video", attributes: titleAttributes)
        controller.setValue(titleString, forKey: "attributedTitle")
        controller.view.tintColor = UIColor.gray
        // ??????
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.takePicture()
        }
        controller.addAction(cameraAction)

        // ??????
        let photoLibraryAction = UIAlertAction(title: "Photolibrary", style: .default) { _ in
            self.openPhotoLibrary()
        }
        controller.addAction(photoLibraryAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancelAction)

        self.present(controller, animated: true, completion: nil)
    }
    /// ????????????
    func takePicture() {
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true)
    }
    /// ????????????
    func openPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        self.present(imagePickerController, animated: true)
    }
}

// MARK: - ImagePickerControllerDelegate
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            uploadedPhoto.append(image)
        }
        if let url = info[.mediaURL] as? URL {
            print(url)
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            var time = asset.duration
            imageGenerator.appliesPreferredTrackTransform = true
            time.value = min(time.value, 2)
            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: imageRef)
                uploadedPhoto.append(image)
            } catch {
                return
            }
        }
        picker.dismiss(animated: true, completion: nil)
        postTableView.reloadData()
    }
}

// MARK: - text field delegate
extension PostViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        } else {
            product.description = textView.text ?? "No description"
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.placeholder {
        case "title":
            product.title = textField.text ?? ""
        case "rent / day":
            guard let rentString = textField.text else { return }
            product.rent = Int(rentString) ?? 0
        case "address":
            product.addressString = textField.text ?? ""
            guard let addressString = textField.text else { return }
            print(addressString)
            convertAddressToGeoPoint(address: addressString)
        case "amount":
            guard let amountString = textField.text else { return }
            product.totalAmount = Int(amountString) ?? 1
        case "classification":
            product.classification = textField.text ?? ""

        default:
            print("error")
        }
    }
// MARK: - Date related function
    func daysBetweenTwoDate() {
        avaliableTerm = []
        let calendar = Calendar.current
        guard startDate < endDate else { return }
        guard let standardStartDate = calendar.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: startDate)?.addingTimeInterval(28800),
              let standardEndDate = calendar.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: endDate)?.addingTimeInterval(28800) else { return }
        let components = calendar.dateComponents([.day], from: standardStartDate, to: standardEndDate)
        guard let days = components.day else { return }
        for round in 0...days {
            guard let dateBeAdded = calendar.date(byAdding: .day, value: round, to: standardStartDate) else { return}
            avaliableTerm.append(dateBeAdded)
        }
        product.availableDate = avaliableTerm
        print(avaliableTerm)
    }
    
    func convertDateStringToDate(textFieldText: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = textFieldText
        guard let date = dateFormatter.date(from: dateString) else { fatalError() }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!  // ??????calendar???TimeZone?????????component???year??????????????????
        var component = calendar.dateComponents([.year, .month, .day], from: date)
        component.year = 2022
        guard let correctDate = calendar.date(from: component) else { fatalError() }
        return correctDate
    }
}

// MARK: - pass date from cell delegate
extension PostViewController: PassDateToPostVCDelegate {
    func passDateRangeToVC() {
        
        let pickerController = CalendarPickerViewController(
            todayDate: Date())
        pickerController.passDateDelegate = self
        tabBarController?.present(pickerController, animated: true, completion: nil)
    }
    
    func passClassificationToVC(text: String) {
        product.classification = text
    }
    
    func passStartDateToVC(chooseDate: Date) {
        startDate = chooseDate
        print(startDate)
//        daysBetweenTwoDate()
    }
    
    func passEndDateToVC(chooseDate: Date) {
        endDate = chooseDate
        print(endDate)
//        daysBetweenTwoDate()
    }
}

// MARK: - Date range delegate
extension PostViewController: PassDateRangeToPostVCDelegate {
    func passDateRange(dateRange: [Date]) {
        toInfoCellDelegate?.askToShowDateRange(dateRange: dateRange)
        startDate = dateRange.first ?? Date()
        endDate = dateRange.last ?? Date()
        daysBetweenTwoDate()
    }
}
