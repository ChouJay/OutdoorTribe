//
//  OrderManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/19.
//

import Foundation
import FirebaseFirestore

class OrderManger {
    static let shared = OrderManger()
    
    func uploadOrder( orderFromVC: inout Order) {
        let firstoreDb = Firestore.firestore()
        let document = firstoreDb.collection("orders").document()
        orderFromVC.orderID = document.documentID
        document.setData(orderFromVC.toDict)
    }
}
