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
    var hintImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "hintImage")
        return imageView
    }()

    @IBOutlet weak var leaseInTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutHintImage()
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
    
    func showCallUI(indexPath: IndexPath, targetUid: String) {
        guard let callVC = storyboard?.instantiateViewController(
            withIdentifier: "CallerViewController") as? CallerViewController else { return }
        callVC.modalPresentationStyle = .fullScreen
        callVC.calleeUid = targetUid
        present(callVC, animated: true, completion: nil)
    }
    
    func layoutHintImage() {
        view.addSubview(hintImageView)
        hintImageView.anchor(top: view.topAnchor,
                             leading: view.leadingAnchor,
                             bottom: view.bottomAnchor,
                             trailing: view.trailingAnchor,
                             width: UIScreen.main.bounds.width,
                             height: view.frame.height)
    }
}

// MARK: - table view dataSource
extension LeaseInViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if leaseOrders.count == 0 {
            hintImageView.isHidden = false
        } else {
            hintImageView.isHidden = true
        }
        return leaseOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "LeaseInTableViewCell",
            for: indexPath) as? LeaseInTableViewCell else { fatalError() }
        guard let urlString = leaseOrders[indexPath.row].product?.photoUrl.first,
              let url = URL(string: urlString) else { return cell }
        cell.callDelegate = self
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

// MARK: - call delegate
extension LeaseInViewController: LeaseInCallDelegate {
    func askVcToCall(cell: UITableViewCell) {
        guard let indexPath = leaseInTableView.indexPath(for: cell) else { return }
        let calleeUid = leaseOrders[indexPath.row].renterUid
        WebRTCClient.shared.currentUserInfo = userInfo
        WebRTCClient.shared.calleeUid = calleeUid
        // signal
        WebRTCClient.shared.offer { [weak self] sdp in
            WebRTCClient.shared.send(sdp: sdp, to: calleeUid) { [weak self] in
                self?.showCallUI(indexPath: indexPath, targetUid: calleeUid)
            }
        }
    }
}
