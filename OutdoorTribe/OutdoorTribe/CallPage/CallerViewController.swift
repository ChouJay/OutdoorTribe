//
//  EndCallViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/10.
//

import UIKit
import Kingfisher

class CallerViewController: UIViewController {

    var calleeUid = ""
    
    @IBOutlet weak var calleePhoto: UIImageView!
    @IBOutlet weak var calleeNameLabel: UILabel!
    @IBOutlet weak var endCallBtn: UIButton!
    
    @IBAction func tapEndCallBtn(_ sender: Any) {
        WebRTCClient.shared.deleteSdpAndCandiadte(for: calleeUid) //  caller!! delete callee sdp & candidate!
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AccountManager.shared.getUserInfo(by: calleeUid) { [weak self] accountInfoFromServer in
            self?.calleeNameLabel.text = accountInfoFromServer.name
            guard let url = URL(string: accountInfoFromServer.photo) else { return }
            self?.calleePhoto.kf.setImage(with: url)
        }
    }
}
