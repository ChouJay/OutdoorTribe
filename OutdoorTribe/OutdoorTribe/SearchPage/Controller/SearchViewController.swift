//
//  SearchViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class SearchViewController: UIViewController {
    var products = [Product]()
    

    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProductManager.shared.retrievePostedProduct { productsFromFireStore in
            self.products = productsFromFireStore
            self.searchTableView.reloadData()
        }
        navigationController?.navigationBar.isHidden = false
        guard let tabBarVc = tabBarController as? TabBarController else { return }
        tabBarVc.plusButton.isHidden = false
    }
}

// MARK: table view delegate
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell else { fatalError() }
        
        guard let urlString = products[indexPath.row].photoUrl.first else { return cell }
        cell.photoImage.kf.setImage(with: URL(string: urlString))
        cell.titleLabel.text = products[indexPath.row].title
        return cell
    }
}

extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        guard let searchTableViewCell = sender as? SearchTableViewCell,
              let detailViewController = segue.destination as? DetailViewController,
              let indexPath = searchTableView.indexPath(for: searchTableViewCell)
        else { return }
        detailViewController.chooseProduct = products[indexPath.row]
    }
}
