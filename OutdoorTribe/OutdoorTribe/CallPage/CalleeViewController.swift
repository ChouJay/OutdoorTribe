//
//  CallerViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/12.
//

import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

class CalleeViewController: UIViewController {
    
    var currentUserID = ""
    var callerAccount: Account?
    
    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var callerPhoto: UIImageView!
    @IBOutlet weak var answerCallBtn: UIButton!
    @IBOutlet weak var cancelCallBtn: UIButton!
    
    @IBAction func tapAnswerCall(_ sender: UIButton) {
        guard let callerAccount = callerAccount else { return }
        answerCallBtn.isEnabled = false
        // WebRTC answer
        WebRTCClient.shared.answer { sdp in
            WebRTCClient.shared.send(sdp: sdp, to: callerAccount.userID) {
                // not put code yet
            }
        }
    }
    
    @IBAction func tapCancelCall(_ sender: UIButton) {
        guard let callerAccount = callerAccount else {
            dismiss(animated: true, completion: nil)
            return }
        WebRTCClient.shared.deleteSdpAndCandiadte(for: callerAccount.userID) // Callee! delete caller sdp & candidate
        WebRTCClient.shared.deleteSdpAndCandiadteByCallee(for: currentUserID)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callerPhoto.layer.cornerRadius = 85
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        currentUserID = currentUid
        Firestore.firestore()
            .collection(currentUid)
            .document("candidate")
            .getDocument(source: .server) { [weak self] documentSnapShot, err in
            if err == nil {
                do {
                    self?.callerAccount = try documentSnapShot?.data(as: Account.self, decoder: Firestore.Decoder())
                    guard let callerAccount = self?.callerAccount else { return }
                    self?.callerNameLabel.text = callerAccount.name
                    guard let url = URL(string: callerAccount.photo) else { return }
                    self?.callerPhoto.kf.setImage(with: url)
                } catch {
                    print(error)
                }
            }
        }
    }
}
