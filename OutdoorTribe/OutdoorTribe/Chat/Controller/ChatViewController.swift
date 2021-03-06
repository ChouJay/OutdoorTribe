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
    var userInfo: Account?
    var allUserInfo = [Account]()
    var otherUserPhotoUrlString = ""
    let imagePickerController = UIImagePickerController()
    var messages = [Message]()
    var sendedPhoto: UIImage?

    var chatRoom = ChatRoom(roomID: "",
                            lastMessage: "hi",
                            lastDate: Date(),
                            chaterOne: "Fake name 1",
                            chaterOneUid: "Fake Uid 1",
                            chaterTwo: "Fake name 2",
                            chaterTwoUid: "Fake Uid 2")
    
    var chatMessage = Message(sender: "Fake name",
                              receiver: "Fake name",
                              message: "",
                              productPhoto: "",
                              date: Date())

    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var typingTextView: UITextView!
    
    @IBAction func tapSendButton(_ sender: UIButton) {
        guard let messageText = typingTextView.text,
              messageText != "" else { return }
        chatMessage.message = messageText
        ChatManager.shared.createChat(in: chatRoom, put: chatMessage)
        typingTextView.text = ""
        sendedPhoto = nil
        ChatManager.shared.updateChatRoomLastMessage(in: chatRoom.roomID, by: messageText)
    }
    
    @IBAction func tapPhotoButton(_ sender: UIButton) {
        choosePhoto()
        ChatManager.shared.updateChatRoomLastMessageIfSendPhoto(in: chatRoom.roomID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        imagePickerController.delegate = self
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        ChatManager.shared.addChatRoomListener(to: chatRoom) { [weak self] messagesFromServer in
            guard let message = self?.messages else { return }
            self?.messages = message + messagesFromServer
            guard let indexRow = self?.messages.count else { return }
            self?.chatTableView.reloadData()
            if indexRow == 0 {
                return
            }
            self?.chatTableView.scrollToRow(at: IndexPath(row: indexRow - 1, section: 0), at: .top, animated: false)
        }        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let usersInChatRoom = chatRoom.users else { return }
        for name in usersInChatRoom where name != userInfo?.name {
            navigationTitle.title = name
            chatMessage.receiver = name
        }
        guard let userInfo = userInfo else { return }
        chatMessage.sender = userInfo.name
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
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatTableViewCell", for: indexPath) as? ChatTableViewCell else { fatalError() }
            guard let userInfo = userInfo else { return cell}
            cell.layOutTextBubble()
            if messages[indexPath.row].sender == userInfo.name {
                cell.rightBubbleView.isHidden = false
                cell.rightTimeLabel.isHidden = false
                cell.leftBubbleView.isHidden = true
                cell.leftTimeLabel.isHidden = true
                cell.photoView.isHidden = true
                cell.rightTextBubble.text = messages[indexPath.row].message
                
                let date = messages[indexPath.row].date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                cell.rightTimeLabel.text = dateString
                
            } else {
                cell.leftBubbleView.isHidden = false
                cell.leftTimeLabel.isHidden = false
                cell.photoView.isHidden = false
                cell.rightBubbleView.isHidden = true
                cell.rightTimeLabel.isHidden = true
                cell.leftTextBubble.text = messages[indexPath.row].message
                // load otherUser photo
                
                let date = messages[indexPath.row].date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                cell.leftTimeLabel.text = dateString

                if otherUserPhotoUrlString != "" {
                    guard let url = URL(string: otherUserPhotoUrlString) else { return cell }
                    cell.photoView.kf.setImage(with: url)
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatImageTableViewCell", for: indexPath) as? ChatImageTableViewCell,
                  let url = URL(string: messages[indexPath.row].productPhoto) else { fatalError() }
            guard let userInfo = userInfo else { return cell}
            cell.layOutImageCell()
            if messages[indexPath.row].sender == userInfo.name {
                cell.rightView.isHidden = false
                cell.rightTimeLabel.isHidden = false
                cell.leftView.isHidden = true
                cell.leftTimeLabel.isHidden = true
                cell.photoView.isHidden = true
                cell.rightImage.kf.setImage(with: url)
                
                let date = messages[indexPath.row].date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                cell.rightTimeLabel.text = dateString

            } else {
                cell.leftView.isHidden = false
                cell.leftTimeLabel.isHidden = false
                cell.rightView.isHidden = true
                cell.rightTimeLabel.isHidden = true
                cell.photoView.isHidden = false
                if otherUserPhotoUrlString != "" {
                    guard let url = URL(string: otherUserPhotoUrlString) else { return cell }
                    cell.photoView.kf.setImage(with: url)
                }
                cell.leftImage.kf.setImage(with: url)
                let date = messages[indexPath.row].date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let dateString = dateFormatter.string(from: date)
                cell.leftTimeLabel.text = dateString
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
        let controller = UIAlertController(title: "???????????????", message: nil, preferredStyle: .actionSheet)
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: UIColor.black]
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
    
    func uploadPhoto() {
        let group: DispatchGroup = DispatchGroup()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "chatImages/\(UUID().uuidString).jpg"
        var urlString = ""
        guard let sendedPhoto = sendedPhoto else { return }
        guard let imageData = sendedPhoto.jpegData(compressionQuality: 0.5) else { return }
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
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            typingTextView.text = ""
            sendedPhoto = image
            uploadPhoto()
            dismiss(animated: true)
        }
    }
}
