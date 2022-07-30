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
    let firestoreAuth = Auth.auth()
    var userInfo: Account?
    var bookedStateOrders = [Order]()
    var hintImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "profileHintPage")
        return imageView
    }()
    
    @IBOutlet weak var bookedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutHintImage()
        bookedTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    func showBookStateInfo(cell: UITableViewCell, isForRenter: Bool, cellForRowAt indexPath: IndexPath) {
        if isForRenter {
            guard let cell = cell as? BookedForRenterTableViewCell else { return }
            cell.changeStateDelegate = self
            cell.orderID = bookedStateOrders[indexPath.row].orderID
            guard let urlString = bookedStateOrders[indexPath.row].product?.photoUrl.first,
                  let url = URL(string: urlString) else { return }
            if bookedStateOrders[indexPath.row].orderState == 1 {
                cell.disableDeliverBtn()
            }
            cell.photoImage.kf.setImage(with: url)
            cell.productName.text = bookedStateOrders[indexPath.row].product?.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            guard let date = bookedStateOrders[indexPath.row].leaseTerm.first else { return }
            let dateString = dateFormatter.string(from: date)
            cell.pickUpdateLabel.text = dateString
        } else {
            guard let cell = cell as? BookedForLessorTableViewCell else { return }
            cell.changeStateDelegate = self
            cell.orderID = bookedStateOrders[indexPath.row].orderID
            guard let urlString = bookedStateOrders[indexPath.row].product?.photoUrl.first,
                  let url = URL(string: urlString) else { return }
            
            if bookedStateOrders[indexPath.row].orderState == 2 {
                cell.disablePickUpBtn()
            }
            cell.bookedPhoto.kf.setImage(with: url)
            cell.productName.text = bookedStateOrders[indexPath.row].product?.title
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            guard let date = bookedStateOrders[indexPath.row].leaseTerm.first else { return }
            let dateString = dateFormatter.string(from: date)
            cell.pickUpDateLabel.text = dateString
        }
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

// MARK: - table View dataSource
extension BookedStageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bookedStateOrders.count == 0 {
            hintImageView.isHidden = false
        } else {
            hintImageView.isHidden = true
        }
        return bookedStateOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bookedStateOrders[indexPath.row].renter == userInfo?.name {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "BookedForRenterTableViewCell",
                for: indexPath) as? BookedForRenterTableViewCell else { fatalError() }
            showBookStateInfo(cell: cell, isForRenter: true, cellForRowAt: indexPath)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "BookedForLessorTableViewCell",
                for: indexPath) as? BookedForLessorTableViewCell else { fatalError() }
            showBookStateInfo(cell: cell, isForRenter: false, cellForRowAt: indexPath)
            return cell
        }
    }
}

// MARK: - change state delegate
extension BookedStageViewController: LessorChangeStateDelegate {
    func askVcToCancelLessorOrder(_ orderID: String) {
        OrderManger.shared.deleteOrderByCancelBtn(orderID)
        print("cancel btn test")
    }
    
    func askVcChangeToPickUpState(_ sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: bookedTableView)
        guard let indexPath = bookedTableView.indexPathForRow(at: buttonPosition) else { return }
        let documentId = bookedStateOrders[indexPath.row].orderID
        OrderManger.shared.updateStateToPickUp(documentId: documentId)
    }
}

extension BookedStageViewController: RenterChangeStateDelegate {
    func askVcToCancelRenterOrder(_ orderID: String) {
        OrderManger.shared.deleteOrderByCancelBtn(orderID)
        print("cancel btn renter test")
    }
    
    func askVcChangeToDeliveredState(_ sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: bookedTableView)
        guard let indexPath = bookedTableView.indexPathForRow(at: buttonPosition) else { return }
        let documentId = bookedStateOrders[indexPath.row].orderID
        OrderManger.shared.updateStateToDeliver(documentId: documentId)
    }
}
