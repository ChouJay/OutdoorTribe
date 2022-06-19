//
//  DetailViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import UIKit
import SwiftUI
import FirebaseFirestore

class DetailViewController: UIViewController {

    var order = Order(lessor: "George", orderID: "", requiredAmount: 0, leaseTerm: [], product: nil)
    var chooseProduct: QueryDocumentSnapshot?
    @IBOutlet weak var detailTableView: UITableView!
    
    @IBAction func tapApplyButton(_ sender: Any) {
        OrderManger.shared.uploadOrder(orderFromVC: &order)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: super.view.frame.width, height: .leastNormalMagnitude))
        detailTableView.automaticallyAdjustsScrollIndicatorInsets = false
//        detailTableView.contentInsetAdjustmentBehavior
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        guard let tabBarVc = tabBarController as? TabBarController else { return }
        tabBarVc.plusButton.isHidden = true
//        tabBarVc.tabBar.isHidden = true
        print(chooseProduct?.data())
    }
}

// MARK: - tableView dataSource
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailGalleryTableViewCell", for: indexPath) as? DetailGalleryTableViewCell else { fatalError() }
            guard let urlStrings = chooseProduct?.data()["photoUrl"] as? [String] else { return cell}
            cell.imageUrlStings = urlStrings
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoTableViewCell", for: indexPath) as? DetailInfoTableViewCell else { fatalError() }
            guard let productName = chooseProduct?.data()["title"] as? String,
                  let addressString = chooseProduct?.data()["address"] as? String,
                  let rentString = chooseProduct?.data()["rent"] as? Int else { return cell }
            cell.nameLabel.text = productName
            cell.addressLabel.text = addressString
            cell.rentLabel.text = String(rentString)
            return cell
        }
    }
}
