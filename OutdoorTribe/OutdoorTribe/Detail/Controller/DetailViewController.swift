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
import FirebaseAuth

protocol AskDetailInfoCellDelegate {
    func askDetailCellToShowDateRange(dateRange: [Date])
}

class DetailViewController: UIViewController {
    
    var askDetailInfoCellDelegate: AskDetailInfoCellDelegate?
    
    let firestoreAuth = Auth.auth()
    var pageController = UIPageControl()
    var renterAccount: Account?
    var userInfo: Account?
    var leaseTerm = [Date]()
    var startDate = Date()
    var endDate = Date()
    var order = Order(lessor: "Fake name",
                      lessorUid: "",
                      renter: "",
                      renterUid: "",
                      orderID: "",
                      requiredAmount: 0,
                      leaseTerm: [],
                      product: nil,
                      createDate: Date())
    lazy var chatRoom = ChatRoom(users: nil,
                            roomID: "",
                            lastMessage: "Hi",
                            lastDate: Date(),
                            chaterOne: "Fake name 1",
                            chaterOneUid: "Fake Uid 1",
                            chaterTwo: "Fake name 2",
                            chaterTwoUid: "Fake Uid 2")
    var chooseProduct: Product?
    
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    
    @IBAction func tapApplyButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        if firebaseAuth.currentUser == nil {
            presentLoginVC()
        } else {
            daysBetweenTwoDate()
            order.lessor = userInfo?.name ?? ""
            order.lessorUid = userInfo?.userID ?? ""
            order.product = chooseProduct
            order.renter = chooseProduct?.renter ?? ""
            order.renterUid = chooseProduct?.renterUid ?? ""
            OrderManger.shared.uploadOrder(orderFromVC: &order)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func tapChatButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        if firebaseAuth.currentUser == nil {
            presentLoginVC()
        } else {
            let uuid = UUID().uuidString
            let chaterOneName = userInfo?.name ?? ""
            let chaterTwoName = chooseProduct?.renter ?? ""
            chatRoom.chaterOne = chaterOneName
            chatRoom.chaterTwo = chaterTwoName
            chatRoom.roomID = uuid
            chatRoom.users = [chaterOneName, chaterTwoName]
            chatRoom.chaterOneUid = userInfo?.userID ?? "Fake Uid"
            chatRoom.chaterTwoUid = chooseProduct?.renterUid ?? "Fake Uid"
            print(chaterOneName)
            print(chaterTwoName)
            ChatManager.shared.createChatRoomIfNeed(
                chatRoom: chatRoom,
                chaterOne: chaterOneName,
                chaterTwo: chaterTwoName) { [weak self] existChatRoom in
                    self?.chatRoom = existChatRoom
                    print(self?.chatRoom)
                    self?.performSegue(withIdentifier: "DetailtoChatRoomSegue", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.tableHeaderView = UIView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: super.view.frame.width,
                          height: .leastNormalMagnitude))
        detailTableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        guard let uid = firestoreAuth.currentUser?.uid else { return }
        AccountManager.shared.getUserInfo(by: uid) { [weak self] account in
            self?.userInfo = account
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        guard let tabBarVc = tabBarController as? TabBarController else { return }
        tabBarVc.plusButton.isHidden = true
        
        guard let chooseProduct = chooseProduct else { return }
        AccountManager.shared.getUserInfo(by: chooseProduct.renterUid) { [weak self] accountFromServer in
            self?.renterAccount = accountFromServer
            self?.detailTableView.reloadData()
            if self?.userInfo?.name == accountFromServer.name {
                self?.chatBtn.isEnabled = false
                self?.chatBtn.alpha = 0.5
                self?.applyBtn.isEnabled = false
                self?.applyBtn.alpha = 0.5
                
            }
        }
    }
    
    func presentLoginVC() {
            guard let childVC = storyboard?.instantiateViewController(
                withIdentifier: "LoginViewController") as? LoginViewController else { return }
            childVC.modalPresentationStyle = .fullScreen
            present(childVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ChatViewController {
            destinationVC.chatRoom = chatRoom
            destinationVC.userInfo = userInfo
            guard let photoUrlString = renterAccount?.photo else { return }
            destinationVC.otherUserPhotoUrlString = photoUrlString
        } else {
            guard let destinationVC = segue.destination as? UserViewController,
                  let posterUid =  chooseProduct?.renterUid else { return }
            destinationVC.othersAccount = renterAccount
            destinationVC.posterUid = posterUid
        }
    }
}

// MARK: - tableView dataSource
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailGalleryTableViewCell",
                for: indexPath) as? DetailGalleryTableViewCell else { fatalError() }
            guard let urlStrings = chooseProduct?.photoUrl else { return cell}
            cell.imageUrlStings = urlStrings
            guard let chooseProduct = chooseProduct else { return cell}
            cell.layoutPageController(chooseProduct: chooseProduct)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "RenterTableViewCell",
                for: indexPath) as? RenterTableViewCell else { fatalError() }
            guard let renterAccount = renterAccount else { return cell }
            cell.photoLayOut()
            cell.nameLabel.text = renterAccount.name
            let totalScore = renterAccount.totalScore
            var score = 0.0
            if renterAccount.ratingCount != 0 {
                score = totalScore / renterAccount.ratingCount
            }
            cell.scoreLabel.text = String(format: "%.1f", score) + "(\(String(Int(renterAccount.ratingCount))))"
        
            if renterAccount.photo != "" {
                guard let url = URL(string: renterAccount.photo) else { return cell }
                cell.renterPhotoImage.kf.setImage(with: url)
            }

            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailInfoTableViewCell",
                for: indexPath) as? DetailInfoTableViewCell else { fatalError() }
            askDetailInfoCellDelegate = cell
            cell.delegate = self
            guard let productName = chooseProduct?.title,
                  let addressString = chooseProduct?.addressString,
                  let rent = chooseProduct?.rent else { return cell }
            cell.nameLabel.text = productName
            cell.addressLabel.text = addressString
            cell.descriptionTextView.text = chooseProduct?.description ?? ""
            return cell

        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "RenterTableViewCell",
                for: indexPath) as? RenterTableViewCell else { fatalError() }
            return cell
        }
    }
}

// MARK: - get date from info cell
extension DetailViewController: askDetailVCPresentDateRangeDelegate {
    func passAmountToVC(requireAmount: String) {
        order.requiredAmount = Int(requireAmount) ?? 0
    }
    
    func askDetailVCPresentDateRangePicker() {
        let pickerController = CalendarPickerViewController(
            todayDate: Date())
        guard let availableDate = chooseProduct?.availableDate else { return }
        pickerController.rentAvailableDate = availableDate
        pickerController.passDateToDetailVCDelegate = self
        present(pickerController, animated: true, completion: nil)
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
                                                    of: startDate.addingTimeInterval(28800)),
              let standardEndDate = calendar.date(bySettingHour: 0,
                                                  minute: 0,
                                                  second: 0,
                                                  of: endDate.addingTimeInterval(28800)) else { return }
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

// MARK: - date range picker delegate
extension DetailViewController: PassDateRangeToDetailVCDelegate {
    func passDateRangeToDetailVC(dateRange: [Date]) {
        askDetailInfoCellDelegate?.askDetailCellToShowDateRange(dateRange: dateRange)
        startDate = dateRange.first ?? Date()
        endDate = dateRange.last ?? Date()
        daysBetweenTwoDate()
    }
}
