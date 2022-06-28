//
//  ChatModal.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/23.
//

import Foundation

struct ChatRoom: Codable {
    var users: [String]?
    var roomID: String
    var lastMessage: String
    var lastDate: Date
    var chaterOne: String
    var chaterTwo: String
    
    var toDict: [String: Any] {
        return [
            "users": users as Any,
            "roomID": roomID as Any,
            "lastMessage": lastMessage as Any,
            "lastDate": lastDate as Any,
            "chaterOne": chaterOne as Any,
            "chaterTwo": chaterTwo as Any
        ]
    }
}

struct Message: Codable {
    var sender: String
    var receiver: String
    var message: String
    var productPhoto: String
    var date: Date
    
    var toDict: [String: Any] {
        return [
            "sender": sender as Any,
            "receiver": receiver as Any,
            "message": message as Any,
            "productPhoto": productPhoto as Any,
            "date": date as Any
        ]
    }
}
