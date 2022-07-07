//
//  BlockViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/7.
//

import UIKit

class BlockViewController: UIViewController {

    var blockAccounts = [Account]()
    @IBOutlet weak var blockTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blockTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - tableView dataSource
extension BlockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTableViewCell", for: indexPath) as? BlockTableViewCell else { fatalError() }
        return cell
    }
}
