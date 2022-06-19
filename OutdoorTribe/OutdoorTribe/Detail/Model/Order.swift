//
//  Order.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import Foundation

struct Order {
    var lessor: String
    var orderID: String
    var requiredAmount: Int
    var leaseTerm: [Date]
    var product: Product?
    var orderState: Int = 0
    
    var toDict: [String: Any] {
        return [
            "lessor": lessor as Any,
            "orderID": orderID as Any,
            "requiredAmount": requiredAmount as Any,
            "leaseTerm": leaseTerm as Any,
            "product": product as Any,
            "orderState": orderState as Any
        ]
    }

}
