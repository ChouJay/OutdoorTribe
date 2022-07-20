//
//  Day.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/16.
//

import Foundation
import SwiftUI

struct Day {
  // 1
    var date: Date
  // 2
    var number: String
  // 3
    let isSelectable: Bool
  // 4
    let isWithinDisplayedMonth: Bool
}

enum MonthOfCalendar: Int {
    case first
    case second
    case third
}
