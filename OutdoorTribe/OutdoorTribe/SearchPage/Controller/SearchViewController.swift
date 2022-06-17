//
//  SearchViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import UIKit
import FirebaseFirestore

class SearchViewController: UIViewController {
    var documentsFromFirestore = [QueryDocumentSnapshot]()
    var products = [Product]()

    @IBOutlet weak var searchTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProductManager.shared.retrievePhotos { documents in
            self.documentsFromFirestore = documents
            self.searchTableView.reloadData()
        }
        print(products)
    }
}


// MARK: table view delegate
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documentsFromFirestore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell else { fatalError() }
        
        guard let urlStrings = documentsFromFirestore[indexPath.row].data()["photoUrl"] as? [String] else { return cell }
        print(urlStrings)
        
        return cell
    }
}
