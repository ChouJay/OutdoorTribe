//
//  BlockViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/7.
//

import UIKit
import Kingfisher

class BlockViewController: UIViewController {

    var blockAccounts = [Account]()
    var userInfo: Account?

    @IBOutlet weak var blockTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blockTableView.dataSource = self
        
        navigationItem.title = "Block list"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userInfo = userInfo else { return }
        AccountManager.shared.loadUserBlockList(byUserID: userInfo.userID) { [weak self] accountInBlockList in
            self?.blockAccounts = accountInBlockList
            self?.blockTableView.reloadData()
        }
    }
}

// MARK: - tableView dataSource
extension BlockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "BlockTableViewCell",
            for: indexPath) as? BlockTableViewCell else { fatalError() }
        cell.removeBlockDelegate = self
        cell.blockNameLabel.text = blockAccounts[indexPath.row].name
        if blockAccounts[indexPath.row].photo != "" {
            let urlString = blockAccounts[indexPath.row].photo
            guard let url = URL(string: urlString) else { return cell }
            cell.blockPhotoView.kf.setImage(with: url)
        }
        return cell
    }
}

// MARK: - remove block delegate
extension BlockViewController: RemoveBlockDelegate {
    func askToRemoveBlock(tapedCell: UITableViewCell) {
        guard let userInfo = userInfo,
              let indexPath = blockTableView.indexPath(for: tapedCell) else { return }

        AccountManager.shared.unBlockUser(
            byUserID: userInfo.userID,
            unBlockUser: blockAccounts[indexPath.row]) { [weak self] in
            self?.blockAccounts.remove(at: indexPath.row)
            self?.blockTableView.reloadData()
        }
    }
}
