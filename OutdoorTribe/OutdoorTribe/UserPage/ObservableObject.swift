//
//  ObservableObject.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/8/24.
//

import Foundation

class ObservableObject<T> {
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: ((T) -> Void)?
    
    init(_ value: T ) {
        self.value = value
    }
    
    func  bind(_ listener: @escaping (T) -> Void) {
        listener(value)
        self.listener = listener
    }
}
