//
//  CallerViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/12.
//

import UIKit
import Kingfisher

class CalleeViewController: UIViewController {
    
    var callerUid = ""

    
    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var callerPhoto: UIImageView!
    @IBOutlet weak var answerCallBtn: UIButton!
    @IBOutlet weak var cancelCallBtn: UIButton!
    
    @IBAction func tapAnswerCall(_ sender: UIButton) {
        // WebRTC answer
        WebRTCClient.shared.answer { [weak self] sdp in
            guard let self = self else { return }
            WebRTCClient.shared.send(sdp: sdp, to: self.callerUid) {
                // not put code yet
            }
        }
    }
    
    @IBAction func tapCancelCall(_ sender: UIButton) {
        WebRTCClient.shared.deleteSdpAndCandiadte(for: callerUid) // Callee! delete caller sdp & candidate
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AccountManager.shared.getUserInfo(by: callerUid) { [weak self] accountInfoFromServer in
            self?.callerNameLabel.text = accountInfoFromServer.name
            guard let url = URL(string: accountInfoFromServer.photo) else { return }
            self?.callerPhoto.kf.setImage(with: url)
        }
        
    }
}
