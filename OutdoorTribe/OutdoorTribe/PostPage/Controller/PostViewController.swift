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

class PostViewController: UIViewController {
  
    var targetCell: ImageTableViewCell?
    var uploadedPhoto = [UIImage]()
    let imagePickerController = UIImagePickerController()
    var product = Product(renter: "Choujay", title: "", rent: 0, address: GeoPoint(latitude: 0, longitude: 0), addressString: "", totalAmount: 0, availableDate: [Date()], description: "", photoUrl: [])
    var startDate = Date()
    var endDate = Date()
    var leaseTerm = [Date]()
    
    @IBOutlet weak var postTableView: UITableView!
    @IBAction func tapPost(_ sender: Any) {
        uploadPhoto()
        uploadedPhoto = []
        dismiss(animated: true)
        postTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.dataSource = self
        postTableView.delegate = self
        imagePickerController.delegate = self
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
        let firstoreDb = Firestore.firestore()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "images/\(UUID().uuidString).jpg"
        var endPoint = 0
        var paths = [String]()
        for image in uploadedPhoto {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            let fileRef = storageRef.child(path + String(endPoint))
            group.enter()
            let uploadTask = fileRef.putData(imageData, metadata: nil) { storageMetadata, error in
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
        
        group.notify(queue: DispatchQueue.main) {
            guard paths.isEmpty == false else { return }
            self.product.photoUrl = paths
            print(self.product.photoUrl)
            firstoreDb.collection("product").document().setData(self.product.toDict)

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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as? ImageTableViewCell else { fatalError() }
            cell.photoDelegate = self
            cell.uploadedPhoto = uploadedPhoto
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell", for: indexPath) as? InfoTableViewCell else { fatalError() }
            cell.titleTextField.delegate = self
            cell.rentTextField.delegate = self
            cell.addressTextField.delegate = self
            cell.beginDateTextField.delegate = self
            cell.lastDateTextField.delegate = self
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as? ImageTableViewCell else { fatalError() }
            return cell
        }
    }
}

// MARK: - post tableView delegate
extension PostViewController: UITableViewDelegate {
}

// MARK: - uploade photo delegate
extension PostViewController: UploadPhotoDelegate {
    func askToUploadPhoto() {
        let controller = UIAlertController(title: "請上傳照片", message: nil, preferredStyle: .actionSheet)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
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
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        self.present(imagePickerController, animated: true)
    }
}

// MARK: - ImagePickerControllerDelegate
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            uploadedPhoto.append(image)
            print(uploadedPhoto)
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
extension PostViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.placeholder {
        case "title":
            product.title = textField.text ?? ""
        case "rent":
            guard let rentString = textField.text else { return }
            product.rent = Int(rentString) ?? 0
        case "address":
            product.addressString = textField.text ?? ""
            // convert address to geoPoint
            guard let addressString = textField.text else { return }
            print(addressString)
            convertAddressToGeoPoint(address: addressString)
        case "amount":
            guard let amountString = textField.text else { return }
            product.totalAmount = Int(amountString) ?? 1
        case "begin date":
            guard let dateString = textField.text else { return }
            startDate = convertDateStringToDate(textFieldText: dateString)
            daysBetweenTwoDate()
            
        case "last date":
            guard let dateString = textField.text else { return }
            endDate = convertDateStringToDate(textFieldText: dateString)
            daysBetweenTwoDate()
            
        default:
            print("error")
        }
    }
// MARK: - Date related function
    func daysBetweenTwoDate() {
        leaseTerm = []
        let calendar = Calendar.current
        guard startDate < endDate else { return }
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        guard let days = components.day else { return }
        for round in 0...days {
            guard let dateBeAdded = calendar.date(byAdding: .day, value: round, to: startDate) else { return}
            leaseTerm.append(dateBeAdded)
        }
        product.availableDate = leaseTerm
        print(leaseTerm)
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
