//
//  BookingStageViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

class BookedStageViewController: UIViewController {
    var userInfo: Account?
    var bookedStateOrders = [Order]()
    @IBOutlet weak var bookedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookedTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let firestoreAuth = Auth.auth()
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
            guard let userInfo = self?.userInfo else { return }
            OrderManger.shared.retrieveBookedOrder(userName: userInfo.name) { [weak self] orders in
                self?.bookedStateOrders = orders
                self?.bookedTableView.reloadData()
            }
        }
    }
}

// MARK: - table View dataSource
extension BookedStageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookedStateOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookedStageTableViewCell", for: indexPath) as? BookedStageTableViewCell else { fatalError() }
        cell.changeStateDelegate = self
        guard let urlString = bookedStateOrders[indexPath.row].product?.photoUrl.first,
              let url = URL(string: urlString) else { return cell }
        cell.bookedPhoto.kf.setImage(with: url)
        return cell
    }
}

// MARK: - change state delegate
extension BookedStageViewController: ChangeStateDelegate {
    func askVcChangeToPickUpState(_ sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: bookedTableView)
        guard let indexPath = bookedTableView.indexPathForRow(at: buttonPosition) else { return }
        let documentId = bookedStateOrders[indexPath.row].orderID
        OrderManger.shared.updateStateToPickUp(documentId: documentId)
    }
    
    func askVcChangeToDeliverState(_ sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: bookedTableView)
        guard let indexPath = bookedTableView.indexPathForRow(at: buttonPosition) else { return }
        let documentId = bookedStateOrders[indexPath.row].orderID
        OrderManger.shared.updateStateToDeliver(documentId: documentId)
    }
}
