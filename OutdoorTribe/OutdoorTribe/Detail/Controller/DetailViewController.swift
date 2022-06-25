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
    var leaseTerm = [Date]()
    var startDate = Date()
    var endDate = Date()
    var order = Order(lessor: "George",
                      renter: "",
                      orderID: "",
                      requiredAmount: 0,
                      leaseTerm: [],
                      product: nil)
    var chooseProduct: Product?
    var chatRoom = ChatRoom(users: nil,
                            roomID: "",
                            lastMessage: "Hi",
                            lastDate: Date(),
                            chaterOne: "Jay",
                            chaterTwo: "George")
    
    @IBOutlet weak var detailTableView: UITableView!
    
    @IBAction func tapApplyButton(_ sender: Any) {
        daysBetweenTwoDate()
        order.product = chooseProduct
        OrderManger.shared.uploadOrder(orderFromVC: &order)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapChatButton(_ sender: Any) {
        let uuid = UUID().uuidString
        chatRoom.roomID = uuid
        ChatManager.shared.createChatRoomIfNeed(chatRoom: chatRoom)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: super.view.frame.width, height: .leastNormalMagnitude))
        detailTableView.automaticallyAdjustsScrollIndicatorInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = true
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
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailGalleryTableViewCell",
                for: indexPath) as? DetailGalleryTableViewCell else { fatalError() }
            guard let urlStrings = chooseProduct?.photoUrl else { return cell}
            cell.imageUrlStings = urlStrings
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailInfoTableViewCell",
                for: indexPath) as? DetailInfoTableViewCell else { fatalError() }
            cell.delegate = self
            guard let productName = chooseProduct?.title,
                  let addressString = chooseProduct?.addressString,
                  let rent = chooseProduct?.rent else { return cell }
            cell.nameLabel.text = productName
            cell.addressLabel.text = addressString
            cell.rentLabel.text = String(rent)
            guard let startDate = chooseProduct?.availableDate.first,
                  let endDate = chooseProduct?.availableDate.last else { return cell }
            cell.setRentLimitedPeriod(head: startDate,
                                      tail: endDate)
            return cell
        }
    }
}

// MARK: - get date from info cell
extension DetailViewController: PassDateToVcDelegate {
    func getEndDate(_ datePicker: UIDatePicker) {
        endDate = datePicker.date.addingTimeInterval(28800)
    }
    
    func getStartDate(_ datePicker: UIDatePicker) {
        startDate = datePicker.date.addingTimeInterval(28800)
    }
}

// MARK: - date relate function
extension DetailViewController {
    func daysBetweenTwoDate() {
        leaseTerm = []
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        guard startDate < endDate else { return }
        guard let standardStartDate = calendar.date(bySettingHour: 0,
                                              minute: 0,
                                              second: 0,
                                              of: startDate),
              let standardEndDate = calendar.date(bySettingHour: 0,
                                                  minute: 0,
                                                  second: 0,
                                                  of: endDate) else { return }
        let components = calendar.dateComponents([.day],
                                                 from: standardStartDate,
                                                 to: standardEndDate)
        print(standardStartDate)
        guard let days = components.day else { return }
        for round in 0...days {
            guard let dateBeAdded = calendar.date(byAdding: .day, value: round, to: standardStartDate) else { return }
            leaseTerm.append(dateBeAdded)
        }
        order.leaseTerm = leaseTerm
        print(leaseTerm)
    }
}
