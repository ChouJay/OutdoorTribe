//
//  SessionDescription.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/5.
//

import Foundation
import WebRTC

/// This enum is a swift wrapper over `RTCSdpType` for easy encode and decode
enum SdpType: String, Codable {
    case offer, prAnswer, answer
    
    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer:
            return .offer // raw value of enum!
        case .answer:
            return .answer
        case .prAnswer:
            return .prAnswer
        }
    }
}

/// This struct is a swift wrapper over `RTCSessionDescription` for easy encode and decode
struct SessionDescription: Codable {
    let sdp: String
    let type: SdpType
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        
        switch rtcSessionDescription.type {
        case .offer:
            self.type = .offer
        case .prAnswer:
            self.type = .prAnswer
        case .answer:
            self.type = .answer
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }
    
    // what is this?? some kind of closure??
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: self.type.rtcSdpType, sdp: self.sdp)
    }
}
