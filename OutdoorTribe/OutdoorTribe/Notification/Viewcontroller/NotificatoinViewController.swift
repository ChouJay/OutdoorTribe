//
//  NotificatoinViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class NotificatoinViewController: UIViewController {
    let firestoreAuth = Auth.auth()
    var userInfo: Account?
    var orderDocumentsFromFirestore = [QueryDocumentSnapshot]()
    var chatRooms = [ChatRoom]()
    lazy var collectionViewFromCell = UICollectionView()
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatRoomTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
            guard let userInfo = self?.userInfo else { return }
            ChatManager.shared.loadingChatRoom(userName: userInfo.name) { [weak self] chatRoomsFromServer in
                self?.chatRooms = chatRoomsFromServer
                self?.chatRoomTableView.reloadSections(IndexSet(integer: 1), with: .none)
            }
            OrderManger.shared.retrieveApplyingOrder(userName: userInfo.name) { documents in
                self?.orderDocumentsFromFirestore = documents
                self?.chatRoomTableView.reloadSections(IndexSet(integer: 0), with: .none)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyTableViewCell", for: indexPath) as? ApplyTableViewCell else { fatalError() }
        
            cell.orderDocumentsFromFirestore = orderDocumentsFromFirestore
            collectionViewFromCell = cell.applyCollectionView
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatListTableViewCell",
                for: indexPath) as? ChatListTableViewCell else { fatalError() }
            guard let usersInChatRoom = chatRooms[indexPath.row].users,
                  let userInfo = userInfo else { return cell }
            for name in usersInChatRoom {
                if name != userInfo.name {
                    cell.chatListName.text =  name
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
            bookingViewController.choosedOrderDocument = orderDocumentsFromFirestore[indexPath.row]
        case "ToChatViewController":
            guard let chatVC = segue.destination as? ChatViewController,
                  let chatListTableViewCell = sender as? ChatListTableViewCell,
                  let indexPath = chatRoomTableView.indexPath(for: chatListTableViewCell) else { return }
            chatVC.userInfo = userInfo
            chatVC.chatRoom = chatRooms[indexPath.row]
            
        default:
            return
        }
    }
}
