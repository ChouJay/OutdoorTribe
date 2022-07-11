//
//  SignalingClient.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/5.
//

import Foundation
import WebRTC
import FirebaseFirestore

protocol SignalClientDelegate: AnyObject {
    
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient,
                      didReceiveRemoteSdp sdp: RTCSessionDescription,
                      didReceiveSender sender: String?)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

class SignalingClient {
    static let shared = SignalingClient()
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    var delegate: SignalClientDelegate?
    
    //  orther device listen SDP and Candidate data and add it into the peer connection
    func listenSdp(from person: String) {
        Firestore.firestore().collection(person).document("sdp").addSnapshotListener { documentSnapshot, error in
            WebRTCClient.shared.createPeerConnection()
            print(WebRTCClient.shared.peerConnection)
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching sdp: \(error)")
                return
            }
            guard let data = documentSnapshot.data() else {
                print("Firestore sdp data was empty.")
                return
            }
            print("Firestore sdp data: \(data)")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                let sessionDescription = try self.decoder.decode(SessionDescription.self, from: jsonData)
    
                self.delegate?.signalClient(self,
                                            didReceiveRemoteSdp: sessionDescription.rtcSessionDescription,
                                            didReceiveSender: person)
            } catch {
                debugPrint("Warning: Could not decode sdp data: \(error)")
                return
            }
        }
    }
    
    func listenCandidate(from person: String) {
        Firestore.firestore()
            .collection(person)
            .document("candidate")
            .collection("candidates")
            .addSnapshotListener { querySnapShot, err in
            guard let documents = querySnapShot?.documents else {
                print("Error fetching documents: \(err)")
                return
            }
            querySnapShot?.documentChanges.forEach({ diff in
                if diff.type == .added {
                    do {
                        print(diff.document.data())
                        // what is ?  why documents.first?
                        let jsonData = try JSONSerialization.data(
                            withJSONObject: documents.first?.data(),
                            options: .prettyPrinted)
                        let iceCandidate = try self.decoder.decode(IceCandidate.self, from: jsonData)
                        print("iceCandidate: \(iceCandidate)")
                        self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
                    } catch {
                        debugPrint("Warning: Could not decode candidate data: \(error)")
                        return
                    }
                }
            })
        }
    }
}
