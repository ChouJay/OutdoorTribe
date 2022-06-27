//
//  ProfileViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var bookingTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func tapLogOutBtn(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch {
            print(error)
        }
    }
    
    @IBOutlet var containViews: [UIView]!
    @IBAction func tapSegmentControl(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        print(containViews)
        for containerView in containViews {
              containerView.isHidden = true
        }
           containViews[sender.selectedSegmentIndex].isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
