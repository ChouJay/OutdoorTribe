//
//  RentOutViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import Kingfisher

class RentOutViewController: UIViewController {

    var rentOrders = [Order]()
    
    @IBOutlet weak var rentOutTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rentOutTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrderManger.shared.retrieveRentedOrder { orders in
            self.rentOrders = orders
            self.rentOutTableView.reloadData()
        }
    }
}

// MARK: - table view dataSource
extension RentOutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rentOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RentOutTableViewCell", for: indexPath) as? RentOutTableViewCell else { fatalError() }
        guard let urlString = rentOrders[indexPath.row].product?.photoUrl.first,
              let url = URL(string: urlString) else { return cell }
        cell.productPhoto.kf.setImage(with: url)
        return cell
    }
}
