//
//  Order.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import Foundation

struct Order: Codable {
    var lessor: String
    var lessorUid: String
    var renter: String
    var renterUid: String
    var orderID: String
    var requiredAmount: Int
    var leaseTerm: [Date]
    var product: Product?
    var orderState: Int = 0
    var createDate: Date
    
    var toDict: [String: Any] {
        return [
            "lessor": lessor as Any,
            "lessorUid": lessorUid as Any,
            "renter": renter as Any,
            "renterUid": renterUid as Any,
            "orderID": orderID as Any,
            "requiredAmount": requiredAmount as Any,
            "leaseTerm": leaseTerm as Any,
            "product": product?.toDict as Any,
            "orderState": orderState as Any,
            "createDate": createDate as Any
        ]
    }

}
