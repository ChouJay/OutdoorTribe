//
//  CallManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/6.
//

import Foundation
import CallKit
import AVFoundation

class CallManager: NSObject {
    static let shared = CallManager()
    let callController = CXCallController()
    let provider: CXProvider
    let uuid = UUID()
    
    override init() {
       let providerConfiguration = CXProviderConfiguration()
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        provider = CXProvider(configuration: providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    func reportIncomingCall(uuid: UUID, handleName: String, completion: (Error) -> Void) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handleName)
        update.hasVideo = false
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            print(error)
        }
    }
    
    func startCall(handleName: String) {
        let handle = CXHandle(type: .generic, value: handleName)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        startCallAction.isVideo = false
        let transaction = CXTransaction(action: startCallAction)
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
    
    func configureAudioSession() -> AVAudioSession {
      print("Configuring audio session")
      let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
        } catch {
            print("Error while configuring audio session: \(error)")
        }
        return session
    }
}

