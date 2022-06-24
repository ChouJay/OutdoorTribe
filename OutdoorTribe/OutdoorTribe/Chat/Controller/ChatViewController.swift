//
//  ChatViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/23.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import Kingfisher

class ChatViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    var chatRoomInfo: ChatRoom?
    var messages = [Message]()
    var sendedPhoto: UIImage?

    var chatRoom = ChatRoom(roomID: "9C6784B5-0B87-4904-B9FA-E93533BDDD7B", lastMessage: "hi", lastDate: Date(), chaterOne: "Jay", chaterTwo: "George")
    var chatMessage = Message(sender: "Jay", receiver: "George", message: "", productPhoto: "", date: Date())
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var typingTextView: UITextView!
    @IBAction func tapSendButton(_ sender: UIButton) {
        guard let messageText = typingTextView.text,
              messageText != "" else { return }
        chatMessage.message = messageText
        ChatManager.shared.createChat(in: chatRoom, put: chatMessage)
        typingTextView.text = ""
        sendedPhoto = nil
    }
    
    @IBAction func tapPhotoButton(_ sender: UIButton) {
        choosePhoto()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        ChatManager.shared.addChatRoomListener(to: chatRoom) { [weak self] messagesFromServer in
            guard let message = self?.messages else { return }
            self?.messages = message + messagesFromServer
            guard var indexRow = self?.messages.count else { return }
            self?.chatTableView.reloadData()
            if indexRow == 0 {
                return
            }
            self?.chatTableView.scrollToRow(at: IndexPath(row: indexRow - 1, section: 0), at: .top, animated: false)
        }        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

// MARK: - table view dataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(messages.count)
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages[indexPath.row].productPhoto == "" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as? ChatTableViewCell else { fatalError() }
            if messages[indexPath.row].sender == "Jay" {
                cell.rightTextBubble.isHidden = false
                cell.leftTextBubble.isHidden = true
                cell.rightTextBubble.text = messages[indexPath.row].message
            } else {
                cell.leftTextBubble.isHidden = false
                cell.rightTextBubble.isHidden = true
                cell.leftTextBubble.text = messages[indexPath.row].message
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageTableViewCell", for: indexPath) as? ChatImageTableViewCell,
                  let url = URL(string: messages[indexPath.row].productPhoto) else { fatalError() }
            if messages[indexPath.row].sender == "Jay" {
                cell.rightImage.isHidden = false
                cell.leftImage.isHidden = true
                cell.rightImage.kf.setImage(with: url)
            } else {
                cell.leftImage.isHidden = false
                cell.rightImage.isHidden = true
                cell.leftImage.kf.setImage(with: url)
            }
            return cell
        }
    }
}

// MARK: - table view delegate
extension ChatViewController: UITableViewDelegate {
}

// MARK: - Upload photo relate
extension ChatViewController {
    func choosePhoto() {
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
    
    
    func uploadPhoto() {
        let group: DispatchGroup = DispatchGroup()
        let firstoreDb = Firestore.firestore()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "chatImages/\(UUID().uuidString).jpg"
        var urlString = ""
        guard let sendedPhoto = sendedPhoto else { return }
        guard let imageData = sendedPhoto.jpegData(compressionQuality: 0.8) else { return }
        let fileRef = storageRef.child(path)
        group.enter()
        fileRef.putData(imageData, metadata: nil) { storageMetadata, error in
            if error == nil && storageMetadata != nil {
                fileRef.downloadURL { url, error in
                    guard let downloadUrl = url else {
                        print(error)
                        return
                    }
                    urlString = downloadUrl.absoluteString
                    group.leave()
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            guard urlString != "" else { return }
            self.chatMessage.productPhoto = urlString
            ChatManager.shared.createChat(in: self.chatRoom, put: self.chatMessage)
        }
    }
}

// MARK: - imagePicker delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            typingTextView.text = ""
            sendedPhoto = image
            uploadPhoto()
            dismiss(animated: true)
        }
    }
}
