//
//  CallerViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/12.
//

import UIKit

class CalleeViewController: UIViewController {

    @IBOutlet weak var answerCallBtn: UIButton!
    @IBOutlet weak var cancelCallBtn: UIButton!
    
    @IBAction func tapAnswerCall(_ sender: UIButton) {
        // WebRTC answer
        WebRTCClient.shared.answer { sdp in
            WebRTCClient.shared.send(sdp: sdp, to: "George") {
                // not put code yet
            }
        }
    }
    
    @IBAction func tapCancelCall(_ sender: UIButton) {
        WebRTCClient.shared.deleteSdpAndCandiadte(for: "George") // Callee! delete caller sdp & candidate
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
