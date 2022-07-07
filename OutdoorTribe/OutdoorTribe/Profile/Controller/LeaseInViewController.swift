//
//  LeaseInViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit
import FirebaseAuth

class LeaseInViewController: UIViewController {
    let firestoreAuth = Auth.auth()
    var leaseOrders = [Order]()
    var userInfo: Account?

    @IBOutlet weak var leaseInTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaseInTableView.dataSource = self
        
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
            guard let userInfo = self?.userInfo else { return }
            
            OrderManger.shared.retrieveLeasingOrder(userName: userInfo.name) { [weak self] orders in
                self?.leaseOrders = orders
                self?.leaseInTableView.reloadData()
            }
        }
    }
}

// MARK: - table view dataSource
extension LeaseInViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        leaseOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "LeaseInTableViewCell",
            for: indexPath) as? LeaseInTableViewCell else { fatalError() }
        guard let urlString = leaseOrders[indexPath.row].product?.photoUrl.first,
              let url = URL(string: urlString) else { return cell }
        cell.returnOrderDelegate = self
        cell.productPhoto.kf.setImage(with: url)
        cell.productName.text = leaseOrders[indexPath.row].product?.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let date = leaseOrders[indexPath.row].leaseTerm.last else { return cell}
        let dateString = dateFormatter.string(from: date)
        cell.returnDateLabel.text = dateString
        
        if leaseOrders[indexPath.row].orderState == 3 {
            cell.enableReturnBtn()
        } else {
            cell.disableReturnBtn()
        }
        return cell
    }
}

// MARK: - prepare for segue
extension LeaseInViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? ScoreViewController,
              let senderButton = sender as? UIButton else { return }
        let buttonPosition = senderButton.convert(senderButton.bounds.origin, to: leaseInTableView)
        if let indexPath = leaseInTableView.indexPathForRow(at: buttonPosition) {
            destinationVC.finishedOrder = leaseOrders[indexPath.row]
        }
    }
}

// MARK: - return order delegate
extension LeaseInViewController: ReturnOrderDelegate {
    func askVcReturnOrder(cell: LeaseInTableViewCell) {
        guard let indexPath = leaseInTableView.indexPath(for: cell) else { return }
        let orderID = leaseOrders[indexPath.row].orderID
        OrderManger.shared.updateStateToReturn(documentId: orderID)
    }
}
