//
//  BookingViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseFirestore

class BookingViewController: UIViewController {
    var choosedOrderDocument: QueryDocumentSnapshot?
    
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
}

// MARK: - table view dataSource
extension BookingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookingPhotoTableViewCell", for: indexPath) as? BookingPhotoTableViewCell else { fatalError() }
            guard let product = choosedOrderDocument?.data()["product"] as? [String: Any] else { return cell }
            guard let urlStringArray = product["photoUrl"] as? [String] else { return cell }
            cell.galleryUrlStrings = urlStringArray
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookingInfoTableViewCell", for: indexPath) as? BookingInfoTableViewCell else { fatalError() }
            return cell
        }
    }
}
