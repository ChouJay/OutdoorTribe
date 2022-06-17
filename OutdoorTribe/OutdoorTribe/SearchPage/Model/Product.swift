//
//  Product.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import Foundation

struct Product {
    var title: String
    var rent: Int
    var address: String
    var amount: Int
    var availableDate: [Date]
    var description: String
    var photoUrl: [String]
    
    var toDict: [String: Any] {
        return [
            "title": title as Any,
            "rent": rent as Any,
            "address": address as Any,
            "amount": amount as Any,
            "availableDate": availableDate as Any,
            "description": description as Any,
            "photoUrl": photoUrl as Any
        ]
    }
}
