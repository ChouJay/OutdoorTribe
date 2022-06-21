//
//  DetailViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import UIKit
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class DetailViewController: UIViewController {

    var order = Order(lessor: "George", renter: "", orderID: "", requiredAmount: 0, leaseTerm: [], product: nil)
    var chooseProduct: Product?
    @IBOutlet weak var detailTableView: UITableView!
    
    @IBAction func tapApplyButton(_ sender: Any) {
        let product: Product?
        order.product = chooseProduct
        OrderManger.shared.uploadOrder(orderFromVC: &order)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: super.view.frame.width, height: .leastNormalMagnitude))
        detailTableView.automaticallyAdjustsScrollIndicatorInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        guard let tabBarVc = tabBarController as? TabBarController else { return }
        tabBarVc.plusButton.isHidden = true
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
            guard let urlStrings = chooseProduct?.photoUrl else { return cell}
            cell.imageUrlStings = urlStrings
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoTableViewCell", for: indexPath) as? DetailInfoTableViewCell else { fatalError() }
            guard let productName = chooseProduct?.title,
                  let addressString = chooseProduct?.addressString,
                  let rent = chooseProduct?.rent else { return cell }
            cell.nameLabel.text = productName
            cell.addressLabel.text = addressString
            cell.rentLabel.text = String(rent)
            return cell
        }
    }
}
