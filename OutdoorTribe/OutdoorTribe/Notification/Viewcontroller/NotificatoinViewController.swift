//
//  NotificatoinViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore

class NotificatoinViewController: UIViewController {
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
        OrderManger.shared.retrieveApplyingOrder { documents in
            self.orderDocumentsFromFirestore = documents
            self.chatRoomTableView.reloadData()
        }
        ChatManager.shared.loadingChatRoom { chatRoomsFromServer in
            self.chatRooms = chatRoomsFromServer
            
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
            if chatRooms[indexPath.row].chaterOne == "Jay" {
                cell.chatListName.text =  chatRooms[indexPath.row].chaterTwo
            } else {
                cell.chatListName.text =  chatRooms[indexPath.row].chaterOne
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
        print(segue.source)
        guard let applyCollectionViewCell = sender as? ApplyCollectionViewCell,
              let bookingViewController = segue.destination as? BookingViewController,
              let indexPath = collectionViewFromCell.indexPath(for: applyCollectionViewCell)
        else { return }
        print(indexPath)
        bookingViewController.choosedOrderDocument = orderDocumentsFromFirestore[indexPath.row]

    }
}
