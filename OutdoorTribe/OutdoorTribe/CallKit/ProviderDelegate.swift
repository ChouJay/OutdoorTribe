//
//  ProviderDelegate.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/6.
//

import Foundation
import CallKit
import AVFoundation

extension CallManager: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        print("providerDidReset")
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // signal!
        WebRTCClient.shared.offer { sdp in
            WebRTCClient.shared.send(sdp: sdp, to: "George")
        }
        // configureAudioSession
        WebRTCClient.shared.rtcAudioSession.audioSessionDidActivate(CallManager.shared.configureAudioSession())
        WebRTCClient.shared.rtcAudioSession.isAudioEnabled = true
        print(provider)
        provider.reportOutgoingCall(with: self.uuid, connectedAt: nil) // 還不明確
        action.fulfill()
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // configure audio session
        WebRTCClient.shared.rtcAudioSession.audioSessionDidActivate(CallManager.shared.configureAudioSession())
        WebRTCClient.shared.rtcAudioSession.isAudioEnabled = true
        // WebRTC answer
        WebRTCClient.shared.answer { sdp in
            WebRTCClient.shared.send(sdp: sdp, to: "George")
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print(CallManager.shared.uuid)
        let endCallAction = CXEndCallAction(call: CallManager.shared.uuid)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction, completion: { error in
            if let error = error {
            print(error)
            }
        })

        WebRTCClient.shared.deleteSdpAndCandiadte(for: "George")
//  simultaneously clean up a green bar flashes on top of the screen
        provider.reportCall(with: CallManager.shared.uuid, endedAt: Date(), reason: CXCallEndedReason.remoteEnded)
        
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // be called after answerCallAction
        CallManager.shared.configureAudioSession() // 不確定要不要留?
        WebRTCClient.shared.rtcAudioSession.isAudioEnabled = true
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        WebRTCClient.shared.rtcAudioSession.audioSessionDidDeactivate(CallManager.shared.configureAudioSession())
    }
}
