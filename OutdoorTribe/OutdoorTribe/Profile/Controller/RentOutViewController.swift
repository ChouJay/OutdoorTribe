//
//  RentOutViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import Kingfisher
import FirebaseAuth

class RentOutViewController: UIViewController {
    let firestoreAuth = Auth.auth()
    var rentOrders = [Order]()
    var userInfo: Account?
    
    @IBOutlet weak var rentOutTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rentOutTableView.dataSource = self
        
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
            guard let userInfo = self?.userInfo else { return }
            
            OrderManger.shared.retrieveRentedOrder(userName: userInfo.name) { [weak self] orders in
                self?.rentOrders = orders
                self?.rentOutTableView.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - table view dataSource
extension RentOutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rentOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RentOutTableViewCell",
            for: indexPath) as? RentOutTableViewCell else { fatalError() }
        guard let urlString = rentOrders[indexPath.row].product?.photoUrl.first,
              let url = URL(string: urlString) else { return cell }
        cell.finishOrderDelegate = self
        cell.productPhoto.kf.setImage(with: url)
        
        if rentOrders[indexPath.row].orderState == 4 {
            cell.enableFinishBtn()
        } else {
            cell.disableFinishBtn()
        }
            
        return cell
    }
}

// MARK: - prepare for segue
extension RentOutViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? ScoreViewController,
              let senderButton = sender as? UIButton else { return }
        let buttonPosition = senderButton.convert(senderButton.bounds.origin, to: rentOutTableView)
        if let indexPath = rentOutTableView.indexPathForRow(at: buttonPosition) {
            destinationVC.finishedOrder = rentOrders[indexPath.row]
        }
    }
}

// MARK: - finish order delegate
extension RentOutViewController: FinishOrderDelegate {
    func askVcFinishOrder(cell: RentOutTableViewCell) {
        guard let indexPath = rentOutTableView.indexPath(for: cell) else { return }
        let orderID = rentOrders[indexPath.row].orderID
        OrderManger.shared.updateStateToFinish(documentId: orderID)
    }
}
