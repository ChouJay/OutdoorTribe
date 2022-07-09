//
//  TabBarController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import UIKit
import FirebaseAuth
import WebRTC

class TabBarController: UITabBarController {

    var childVc: PostViewController?
    let plusButton = UIButton()
    
    @objc func tapPlus() {
        print("test")
        childVc?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(childVc ?? PostViewController(), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.layer.cornerRadius = 10
        self.delegate = self
        SignalingClient.shared.delegate = self
        SignalingClient.shared.listenSdp(from: "Jay")
        SignalingClient.shared.listenCandidate(from: "Jay")
        
//        tabBar.layer.shadowColor = UIColor.yellow.cgColor
//        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
//        tabBar.layer.shadowRadius = 15
//        tabBar.layer.shadowOpacity = 1
//        tabBar.layer.masksToBounds = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    func setUpPlusButtonUI() {
        plusButton.layer.cornerRadius = 25
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .large)
        plusButton.tintColor = .brown
        plusButton.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        plusButton.addTarget(self, action: #selector(tapPlus), for: .touchUpInside)
        view.addSubview(plusButton)
        plusButton.backgroundColor = .systemGray6
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.centerYAnchor.constraint(equalTo: self.tabBar.centerYAnchor, constant: -40).isActive = true
        plusButton.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag >= 2 {
            let firebaseAuth = Auth.auth()
            if firebaseAuth.currentUser == nil {
                guard let childVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return false }
                childVC.modalPresentationStyle = .fullScreen
                present(childVC, animated: true, completion: nil)
                return false
            }
            return true
        } else {
            return true
        }
    }
}

// SignalClient delegate
extension TabBarController: SignalClientDelegate {
    func signalClient(_ signalClient: SignalingClient,
                      didReceiveRemoteSdp sdp: RTCSessionDescription,
                      didReceiveSender sender: String?) {
        print("Received remote sdp")
        WebRTCClient.shared.peerConnection?.setRemoteDescription(sdp, completionHandler: { error in
            if error != nil {
                print(error)
            } else {
                print("sdp sender: \(sender)")
            }
        })
        print(sdp.type.rawValue)
        if sdp.type.rawValue == 0 {
            CallManager.shared.reportIncomingCall(uuid: CallManager.shared.uuid, handleName: "George") { err in
                print(err)
            }
        } else {
            CallManager.shared.provider.reportOutgoingCall(with: CallManager.shared.uuid, startedConnectingAt: nil)
        }
        print("Received sender")
//        self.oppositePerson = sender ?? ""
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
//        self.remoteCandidateCount += 1
        WebRTCClient.shared.peerConnection?.add(candidate)
        
    }
    
    func signalClientDidConnect(_ signalClient: SignalingClient) {
//        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
//        self.signalingConnected = false
    }
}
