//
//  SubscribeViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit
import FirebaseAuth

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
        guard let currentUser = firebaseAuth.currentUser else { return }
        SubscribeManager.shared.loadingSubscriber(currentUserID: currentUser.uid) { [weak self] accountsFromServer in
            self?.subscribers = accountsFromServer
            self?.subscribeTableView.reloadData()
        }
        
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
        return cell
    }
}

// MARK: - remove subscription delegate
extension SubscribeViewController: RemoveSubscriptionDelegate {
    func askToRecallSubscription(sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: subscribeTableView)
        if let indexPath = subscribeTableView.indexPathForRow(at: buttonPosition) {
            guard let currentUser = firebaseAuth.currentUser else { return }
            SubscribeManager.shared.recallFollow(currentUserID: currentUser.uid, otherUser: subscribers[indexPath.row]) { [weak self] in
                self?.subscribers.remove(at: indexPath.row)
                self?.subscribeTableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
}