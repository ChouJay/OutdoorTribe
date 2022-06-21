//
//  Product.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import Foundation
import FirebaseFirestore

struct Product: Codable {
    var renter: String
//    var lessor: String
    var title: String
    var rent: Int
    var address: GeoPoint
    var addressString: String
    var totalAmount: Int
    var availableDate: [Date]
    var description: String
    var photoUrl: [String]
    
    var toDict: [String: Any] {
        return [
            "renter": renter as Any,
//            "lessor": lessor as Any,
            "title": title as Any,
            "rent": rent as Any,
            "address": address as Any,
            "addressString": addressString as Any,
            "totalAmount": totalAmount as Any,
            "availableDate": availableDate as Any,
            "description": description as Any,
            "photoUrl": photoUrl as Any
        ]
    }
}
