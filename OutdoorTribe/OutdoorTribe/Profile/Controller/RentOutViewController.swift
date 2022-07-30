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
    var hintImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "profileHintPage")
        return imageView
    }()
    
    @IBOutlet weak var rentOutTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutHintImage()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
extension RentOutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rentOrders.count == 0 {
            hintImageView.isHidden = false
        } else {
            hintImageView.isHidden = true
        }
        return rentOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RentOutTableViewCell",
            for: indexPath) as? RentOutTableViewCell else { fatalError() }
        guard let urlString = rentOrders[indexPath.row].product?.photoUrl.first,
              let url = URL(string: urlString) else { return cell }
        cell.callDelegate = self
        cell.finishOrderDelegate = self
        cell.productPhoto.kf.setImage(with: url)
        cell.productName.text = rentOrders[indexPath.row].product?.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let date = rentOrders[indexPath.row].leaseTerm.last else { return cell}
        let dateString = dateFormatter.string(from: date)
        cell.returnDateLabel.text = dateString
        
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

// MARK: - call delegate
extension RentOutViewController: RentOutCallDelegate {
    func askVcToCall(cell: UITableViewCell) {
        guard let indexPath = rentOutTableView.indexPath(for: cell) else { return }
        let calleeUid = rentOrders[indexPath.row].lessorUid
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
