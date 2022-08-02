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
  
    let firestoreAuth = Auth.auth()
    let imagePickerController = UIImagePickerController()
    var userInfo: Account?
    var targetCell: ImageTableViewCell?
    var uploadedPhoto = [UIImage]()
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
        ProductManager.shared.upload(with: uploadedPhoto, in: product)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
        }
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
            self.product.address = GeoPoint(latitude: latitude, longitude: longitude)
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
            cell.amountTextField.delegate = self
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
        let controller = UIAlertController(title: "請上傳照片", message: nil, preferredStyle: .actionSheet)
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let titleString = NSAttributedString(string: "Please upload some photos", attributes: titleAttributes)
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
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            uploadedPhoto.append(image)
        }
        if let url = info[.mediaURL] as? URL {
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
        calendar.timeZone = TimeZone(identifier: "UTC")!  // 指定calendar的TimeZone這樣用component改year才不會差一天
        var component = calendar.dateComponents([.year, .month, .day], from: date)
        component.year = 2022
        guard let correctDate = calendar.date(from: component) else { fatalError() }
        return correctDate
    }
}

// MARK: - pass date from cell delegate
extension PostViewController: PassInfoToPostVCDelegate {
    func passDateRangeToVC() {
        
        let pickerController = CalendarPickerViewController(
            todayDate: Date())
        pickerController.passDateToPostVCDelegate = self
        tabBarController?.present(pickerController, animated: true, completion: nil)
    }
    
    func passClassificationToVC(text: String) {
        product.classification = text
    }
    
    func passStartDateToVC(chooseDate: Date) {
        startDate = chooseDate
    }
    
    func passEndDateToVC(chooseDate: Date) {
        endDate = chooseDate
    }
}

// MARK: - Date range delegate
extension PostViewController: PassDateRangeToPostVCDelegate {
    func passDateRangeToPostVC(dateRange: [Date]) {
        toInfoCellDelegate?.askToShowDateRange(dateRange: dateRange)
        startDate = dateRange.first ?? Date()
        endDate = dateRange.last ?? Date()
        daysBetweenTwoDate()
    }
}
