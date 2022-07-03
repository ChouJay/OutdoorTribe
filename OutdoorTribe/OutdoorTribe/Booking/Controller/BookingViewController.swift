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
    var choosedOrderDocument: QueryDocumentSnapshot?
    var applyOrder: Order?
    
    @IBOutlet weak var bookInfoTableView: UITableView!
    
    @IBAction func tapAgreeButton(_ sender: UIButton) {
        guard let documentID = choosedOrderDocument?.data()["orderID"] as? String else { return }
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
        
        do {
            applyOrder = try choosedOrderDocument?.data(as: Order.self, decoder: Firestore.Decoder())
            guard let applyOrder = applyOrder else { return }
        } catch {
            print("decode failure: \(error)")
        }
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
            guard let product = choosedOrderDocument?.data()["product"] as? [String: Any] else { return cell }
            guard let urlStringArray = product["photoUrl"] as? [String] else { return cell }
            cell.galleryUrlStrings = urlStringArray
            cell.layoutPageController()
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "BookingInfoTableViewCell",
                for: indexPath) as? BookingInfoTableViewCell else { fatalError() }
            cell.lessorNameLabel.text = applyOrder?.lessor
            cell.productName.text = applyOrder?.product?.title
            cell.addressLabel.text = applyOrder?.product?.addressString
            guard let requiredAmount = applyOrder?.requiredAmount else { return cell }
            cell.amountLabel.text = String(requiredAmount)
            
            return cell
        }
    }
}
