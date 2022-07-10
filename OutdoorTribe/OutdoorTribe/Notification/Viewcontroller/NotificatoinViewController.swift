//
//  NotificatoinViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

class NotificatoinViewController: UIViewController {
    
    let firestoreAuth = Auth.auth()
    var allUserInfo = [Account]()
    var blockUsers = [Account]()
    var userInfo: Account?
    var applyingOrders = [Order]()
    var chatRooms = [ChatRoom]()
    lazy var collectionViewFromCell = UICollectionView()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccountManager.shared.getAllUserInfo { [weak self] allUserInfoFromServer in
            self?.allUserInfo = allUserInfoFromServer
        }
        
        chatRoomTableView.dataSource = self
        chatRoomTableView.delegate = self
        chatRoomTableView.register(
            UINib(nibName: "MessageHeaderView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: MessageHeaderView.reuseIdentifier)
        chatRoomTableView.register(
            UINib(nibName: "ApplicationHeaderView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: ApplicationHeaderView.reuseIdentifier)
        chatRoomTableView.sectionHeaderTopPadding = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.loadUserBlockList(byUserID: uid) { [weak self] accounts in
            self?.blockUsers = accounts
            AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
                self?.userInfo = account
                guard let userInfo = self?.userInfo else { return }
                ChatManager.shared.loadingChatRoom(userName: userInfo.name) { [weak self] chatRoomsFromServer in
                    if self?.blockUsers.count == 0 {
                        self?.chatRooms = chatRoomsFromServer
                    } else {
                        self?.chatRooms = []
                        for chatRoom in chatRoomsFromServer {
                            guard let blockUsers = self?.blockUsers else { return }
                            for blockUser in blockUsers {
                                if chatRoom.chaterOne != blockUser.name && chatRoom.chaterTwo != blockUser.name {
                                    self?.chatRooms.append(chatRoom)
                                }
                            }
                        }
                    }
                    self?.chatRoomTableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
                OrderManger.shared.retrieveApplyingOrder(userName: userInfo.name) { ordersFromFirestore in
                    if self?.blockUsers.count == 0 {
                        self?.applyingOrders = ordersFromFirestore
                    } else {
                        self?.applyingOrders = []
                        for order in ordersFromFirestore {
                            guard let blockUsers = self?.blockUsers else { return }
                            for blockUser in blockUsers {
                                if order.lessorUid != blockUser.userID {
                                    self?.applyingOrders.append(order)
                                }
                            }
                        }
                    }
                    self?.chatRoomTableView.reloadSections(IndexSet(integer: 0), with: .none)
                }
            }
        }
    }
}

// MARK: - table view dataSource
extension NotificatoinViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return chatRooms.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ApplyTableViewCell",
                for: indexPath) as? ApplyTableViewCell else { fatalError() }
        
            cell.applyingOrders = applyingOrders
            collectionViewFromCell = cell.applyCollectionView
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatListTableViewCell",
                for: indexPath) as? ChatListTableViewCell else { fatalError() }
            guard let usersInChatRoom = chatRooms[indexPath.row].users,
                  let userInfo = userInfo else { return cell }
            for name in usersInChatRoom where name != userInfo.name {
                cell.chatListName.text =  name
                cell.lastMessageLabel.text = chatRooms[indexPath.row].lastMessage
                let lastDate = chatRooms[indexPath.row].lastDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                let lastDateString = dateFormatter.string(from: lastDate)
                cell.lastSendTimeLabel.text = lastDateString
                for user in allUserInfo where user.name == name {
                    guard user.photo != "" else { break }
                    if let url = URL(string: user.photo) {
                        cell.otherUserPhotoUrlString = user.photo
                        cell.chatListPhoto.kf.setImage(with: url)
                    }
                }
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ApplyTableViewCell",
                for: indexPath) as? ApplyTableViewCell else { fatalError() }
            return cell
        }
    }
}

// MARK: - table view delegate
extension NotificatoinViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: MessageHeaderView.reuseIdentifier) as? MessageHeaderView else { return nil }
            return headerView
        } else {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: ApplicationHeaderView.reuseIdentifier) as? ApplicationHeaderView else { return nil }
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}

// MARK: - segue
extension NotificatoinViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ToBookingViewController":
            guard let applyCollectionViewCell = sender as? ApplyCollectionViewCell,
                  let bookingViewController = segue.destination as? BookingViewController,
                  let indexPath = collectionViewFromCell.indexPath(for: applyCollectionViewCell)
            else { return }
            print(indexPath)
            bookingViewController.applyingOrder = applyingOrders[indexPath.row]
        case "ToChatViewController":
            guard let chatVC = segue.destination as? ChatViewController,
                  let chatListTableViewCell = sender as? ChatListTableViewCell,
                  let indexPath = chatRoomTableView.indexPath(for: chatListTableViewCell),
                  let cell = chatRoomTableView.cellForRow(at: indexPath) as? ChatListTableViewCell else { return }
                    
            chatVC.userInfo = userInfo
            chatVC.chatRoom = chatRooms[indexPath.row]
            chatVC.allUserInfo = allUserInfo
            chatVC.otherUserPhotoUrlString = cell.otherUserPhotoUrlString
            
        default:
            return
        }
    }
}
