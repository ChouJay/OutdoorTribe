//
//  SubscribeViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit
import FirebaseAuth
import Kingfisher

class SubscribeViewController: UIViewController {
    let firebaseAuth = Auth.auth()
    var subscribers = [Account]()
    @IBOutlet weak var subscribeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - table view dataSource
extension SubscribeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subscribers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubscribeTableViewCell",
            for: indexPath) as? SubscribeTableViewCell else { fatalError() }
        cell.removeSubscriptionDelegate = self
        cell.nameLabel.text = subscribers[indexPath.row].name
        if subscribers[indexPath.row].photo != "" {
            guard let url = URL(string: subscribers[indexPath.row].photo) else { return cell }
            cell.photoImage.kf.setImage(with: url)
        }
        return cell
    }
}

// MARK: - remove subscription delegate
extension SubscribeViewController: RemoveSubscriptionDelegate {
    func askToRecallSubscription(sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: subscribeTableView)
        if let indexPath = subscribeTableView.indexPathForRow(at: buttonPosition) {
            guard let currentUser = firebaseAuth.currentUser else { return }
            SubscribeManager.shared.recallFollow(
                currentUserID: currentUser.uid,
                otherUser: subscribers[indexPath.row]) { [weak self] in
                self?.subscribers.remove(at: indexPath.row)
                self?.subscribeTableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
}

// MARK: - prepare for segue
extension SubscribeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? UserViewController,
              let cell = sender as? SubscribeTableViewCell,
              let indexPath = subscribeTableView.indexPath(for: cell) else { return }
        
//        guard let posterUid =  chooseProduct?.renterUid else { return }
        destinationVC.othersAccount = subscribers[indexPath.row]
        destinationVC.posterUid = subscribers[indexPath.row].userID
        
    }
}
