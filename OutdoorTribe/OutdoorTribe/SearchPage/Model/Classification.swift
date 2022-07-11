//
//  Classification.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/22.
//

import Foundation

class Classification {
    static let shared = Classification()
    
    var differentOutdoorType = [
        "Camping",
        "Hiking",
        "Climbing",
        "Skiing",
        "Diving",
        "Surfing",
        "Others"]
}

class AdvertisingWall {
    static let shared = AdvertisingWall()
    
    var differentPicture = [
    "campingPhoto",
    "divingPhoto",
    "skiingPhoto"
    ]
}
