//
//  BookingViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookingViewController: UIViewController {
    var applyingOrder: Order?
    
    @IBOutlet weak var bookInfoTableView: UITableView!
    
    @IBAction func tapAgreeButton(_ sender: UIButton) {
        guard let documentID = applyingOrder?.orderID else { return }
        OrderManger.shared.updateStateToBooked(documentId: documentID)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookInfoTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - table view dataSource
extension BookingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "BookingPhotoTableViewCell",
                for: indexPath) as? BookingPhotoTableViewCell else { fatalError() }
            guard let product = applyingOrder?.product else { return cell }
            guard let urlStringArray = applyingOrder?.product?.photoUrl else { return cell }
            cell.galleryUrlStrings = urlStringArray
            cell.layoutPageController()
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "BookingInfoTableViewCell",
                for: indexPath) as? BookingInfoTableViewCell else { fatalError() }
            cell.lessorNameLabel.text = applyingOrder?.lessor
            cell.productName.text = applyingOrder?.product?.title
            cell.addressLabel.text = applyingOrder?.product?.addressString
            guard let requiredAmount = applyingOrder?.requiredAmount else { return cell }
            cell.amountLabel.text = String(requiredAmount)
            
            return cell
        }
    }
}
