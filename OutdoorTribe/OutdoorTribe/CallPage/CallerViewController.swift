//
//  EndCallViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/10.
//

import UIKit

class CallerViewController: UIViewController {

    @IBOutlet weak var calleeNameLabel: UILabel!
    @IBOutlet weak var endCallBtn: UIButton!
    
    @IBAction func tapEndCallBtn(_ sender: Any) {
        WebRTCClient.shared.deleteSdpAndCandiadte(for: "George") //  caller!! delete callee sdp & candidate!
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
