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
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // configure audio session
        WebRTCClient.shared.rtcAudioSession.audioSessionDidActivate(CallManager.shared.configureAudioSession())
        WebRTCClient.shared.rtcAudioSession.isAudioEnabled = true
        // WebRTC answer
        WebRTCClient.shared.answer { sdp in
            WebRTCClient.shared.send(sdp: sdp, to: "Jay")
            provider.reportOutgoingCall(with: self.uuid, connectedAt: nil)
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // be called after answerCallAction
        CallManager.shared.configureAudioSession() // 不確定要不要留
        WebRTCClient.shared.rtcAudioSession.isAudioEnabled = true
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        
        // signal!
        WebRTCClient.shared.offer { sdp in
            WebRTCClient.shared.send(sdp: sdp, to: "Jay")
        }
        // configureAudioSession
        WebRTCClient.shared.rtcAudioSession.audioSessionDidActivate(CallManager.shared.configureAudioSession())
        WebRTCClient.shared.rtcAudioSession.isAudioEnabled = true
        action.fulfill()
        
    }
}
