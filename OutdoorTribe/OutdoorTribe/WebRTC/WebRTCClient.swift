//
//  WebRtcClient.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/4.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import WebRTC

class WebRTCClient: NSObject {
    static let shared = WebRTCClient(iceServers: Config.defaultIce.webRTCIceServers)
    
    var iceServers: [String]
    var peerConnection: RTCPeerConnection? // why we don't need "?"
   // what is factory?  not get it!
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    // what is mediaConstrains? not get it!
    let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                           kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    let rtcAudioSession =  RTCAudioSession.sharedInstance()
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    init(iceServers: [String]) {
        self.iceServers = iceServers
        super.init() // why we need this?
        createPeerConnection()
    }
// MARK: - peerConnection
    func createPeerConnection() {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
    
        config.sdpSemantics = .unifiedPlan
    
        config.continualGatheringPolicy = .gatherContinually
        
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
        
        peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: self)
        
        createMediaSenders()  // set up audioTrack & add it into peerConnection => still not send!
        configureAudioSession()
        
    }
    
    func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = createAudioTrack()
        peerConnection?.add(audioTrack, streamIds: [streamId]) // return the newly created RTCRtpSender
    }
    
    func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    func configureAudioSession() {
        // Request exclusive access to the audio session for configuration.
        // This call will block if the lock is held by another object
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration() // Relinquishes exclusive access to the audio session
    }
    
// MARK: - signaling
    // offer : just use webRTC sdk create a sdp -> prepare to send!!
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        self.peerConnection?.offer(for: constrains, completionHandler: { sdp, error in
            guard let sdp = sdp else {
                print(error)
                return
            }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { _ in
                completion(sdp) // pass sdp to someone who call this func
            })
        })
    }
    
    func send(sdp rtcSdp: RTCSessionDescription, to person: String) {
        do {
            let dataMessage = try self.encoder.encode(SessionDescription(from: rtcSdp))
            guard let dict = try JSONSerialization.jsonObject(
                with: (dataMessage),
                options: .fragmentsAllowed) as? [String: Any] else { return }
            Firestore.firestore().collection(person).document("sdp").setData(dict) { err in
                if let err = err {
                    print("Error send sdp: \(err)")
                } else {
                    print("sdp sent!!")
                }
            }
        } catch {
            debugPrint("Warning: could not encode sdp: \(error)")
        }
    }
    // After that peer connection auto generate local candidates. You also need to send them to the other person.
    func send(candidate rtcIceCandidate: RTCIceCandidate, to person: String) {
        do {
            // what is iceCandidate
            let dataMessage = try self.encoder.encode(IceCandidate(from: rtcIceCandidate))
            guard let dict = try JSONSerialization.jsonObject(
                with: dataMessage,
                options: .fragmentsAllowed) as? [String: Any] else { return }
            Firestore.firestore()
                .collection(person)
                .document("candidate")
                .collection("candidates")
                .addDocument(data: dict) { err in
                if let err = err {
                    print("Error send candidate: \(err)")
                } else {
                    print("Candidate sent!")
                }
            }
            Firestore.firestore()
                .collection(person)
                .document("candidate")
                .setData(["sender": "Jay"]) { err in
                if let err = err {
                    print("Error send candidate: \(err)")
                } else {
                    print("sender sent!")
                }
            }
        } catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
    
// MARK: - Device B create answer SDP and send it along with Candidates to device A thru Firestore
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
         let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        print(peerConnection)
        peerConnection?.answer(for: constrains, completionHandler: { sdp, err in
            guard let sdp = sdp else {
                print(err)
                return
            }
            
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { error in
                completion(sdp)
            })
        })
    }

// MARK: - Close peer connection, clear Firestore, reset variables and re-create new peer connection, so it ready for new session
    func deleteSdpAndCandiadte(for person: String) {
        closePeerConnection()
        Firestore.firestore()
            .collection(person)
            .document("sdp")
            .delete() { err in
            if let err = err {
                print("Error removing firestore sdp: \(err)")
            } else {
                Firestore.firestore()
                    .collection(person)
                    .document("candidate")
                    .collection("candidates")
                    .getDocuments(source: .server, completion: { querySnapShot, err in
                    if err == nil {
                        guard let querySnapShot = querySnapShot else { return }
                        for document in querySnapShot.documents {
                            document.reference.delete()
                        }
                        print("Firestore candidate successfully removed!")
                        Firestore.firestore()
                            .collection(person)
                            .document("candidate")
                            .delete()
                    } else {
                            print(err)
                    }
                })
                print("Firestore sdp successfully removed!")
            }
        }
    }
    
    func closePeerConnection() {
        peerConnection?.close()
        peerConnection = nil
    }
}

// RTCPeerConnectionDeleger
extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
//        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    // will be called, when we call peerConnection.answer()!!
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        send(candidate: candidate, to: "George") //是否只有offer時會call, 還是answer也會？ 感覺answer也要call 較合理
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
//        self.remoteDataChannel = dataChannel
    }
}
