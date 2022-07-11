//
//  Account.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import Foundation

struct Account: Codable {
    var email: String
    var userID: String
    var providerID: String
    var name: String
    var photo: String
    var totalScore: Double
    var ratingCount: Double
    var createDate: Date = Date()
    var point: Int
    var followerCount: Int
    
    var toDict: [String: Any] {
        return [
            "email": email as Any,
            "userID": userID as Any,
            "providerID": providerID as Any,
            "name": name as Any,
            "photo": photo as Any,
            "totalScore": totalScore as Any,
            "ratingCount": ratingCount as Any,
            "createDate": createDate as Any,
            "point": point as Any,
            "followerCount": followerCount as Any
        ]
    }
}
