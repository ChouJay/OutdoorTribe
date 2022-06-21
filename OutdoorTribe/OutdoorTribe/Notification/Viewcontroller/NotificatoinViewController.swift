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
    }
}

// MARK: - table view dataSource
extension NotificatoinViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyTableViewCell", for: indexPath) as? ApplyTableViewCell else { fatalError() }
        
            cell.orderDocumentsFromFirestore = orderDocumentsFromFirestore
            collectionViewFromCell = cell.applyCollectionView
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as? ChatTableViewCell else { fatalError() }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyTableViewCell", for: indexPath) as? ApplyTableViewCell else { fatalError() }
            return cell
        }
    }
}

// MARK: - segue
extension NotificatoinViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        print(segue.source)
        guard let applyCollectionViewCell = sender as? ApplyCollectionViewCell,
              let bookingViewController = segue.destination as? BookingViewController,
              let indexPath = collectionViewFromCell.indexPath(for: applyCollectionViewCell)
        else { return }
        print(indexPath)
        bookingViewController.choosedOrderDocument = orderDocumentsFromFirestore[indexPath.row]

    }
}
