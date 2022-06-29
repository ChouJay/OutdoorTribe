//
//  ScoreViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import UIKit
import Cosmos
import FirebaseAuth

class ScoreViewController: UIViewController {

    let firebaseAuth = Auth.auth()
    var finishedOrder: Order?
    
    @IBOutlet weak var scoreView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreView.didFinishTouchingCosmos = { [weak self] rating in
            guard let finishedOrder = self?.finishedOrder,
                  let currentUserUid = self?.firebaseAuth.currentUser?.uid else { return }
            if finishedOrder.lessorUid == currentUserUid {
                let userID = finishedOrder.renterUid
                AccountManager.shared.ratingUser(userID: userID, score: rating)
                self?.dismiss(animated: true, completion: nil)
            } else {
                let userID = finishedOrder.lessorUid
                AccountManager.shared.ratingUser(userID: userID, score: rating)
                self?.dismiss(animated: true, completion: nil)
            }
        }
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
