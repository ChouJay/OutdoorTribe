//
//  UserModel.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/23.
//

import Foundation

struct User: Codable {
    var email: String
    var userID: String
    var point: Int
    var score: Double
    var photoUrl: String
    
    var toDict: [String: Any] {
        return [
            "email": email as Any,
            "userID": userID as Any,
            "point": point as Any,
            "score": score as Any,
            "photoUrl": photoUrl as Any
        ]
    }
}
