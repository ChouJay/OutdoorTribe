//
//  Account.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import Foundation

struct Account {
    var email: String
    var userID: String
    var providerID: String
    var name: String
    var photo: String
    var score: [Int]
    var createDate: Date = Date()
    var point: Int
    
    var toDict: [String: Any] {
        return [
            "email": email as Any,
            "userID": userID as Any,
            "providerID": providerID as Any,
            "name": name as Any,
            "photo": photo as Any,
            "score": score as Any,
            "createDate": createDate as Any,
            "point": point as Any
        ]
    }
}
