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
    
    func retrieveRentedOrder(_ completion: @escaping ([Order]) -> ()) {
        var orders = [Order]()
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders").whereField("orderState", isEqualTo: 3).getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    let order: Order?
                    do {
                        order = try document.data(as: Order.self, decoder: Firestore.Decoder())
                        guard let order = order else { return }
                        orders.append(order)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(orders)
            }
        }
    }

    
    func retrieveBookedOrder(userName: String,_ completion: @escaping ([Order]) -> ()) {
        var orders = [Order]()
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders")
            .whereField("orderState", isLessThan: 3)
            .whereField("orderState", isNotEqualTo: 0)
            .whereField("renter", isEqualTo: userName)
            .getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {                    
                    let order: Order?
                    do {
                        order = try document.data(as: Order.self, decoder: Firestore.Decoder())
                        guard let order = order else { return }
                        orders.append(order)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(orders)
            }
        }
    }
    
    func retrieveApplyingOrder(userName: String,_ completion: @escaping ([QueryDocumentSnapshot]) -> ()) {
        var documents = [QueryDocumentSnapshot]()
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders").whereField("orderState", isEqualTo: 0).whereField("renter", isEqualTo: userName).getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    documents.append(document)
                    print(documents)
                }
                completion(documents)
            }
        }
    }
    
    func uploadOrder(orderFromVC: inout Order) {
        let firstoreDb = Firestore.firestore()
        let document = firstoreDb.collection("orders").document()
        orderFromVC.orderID = document.documentID
        document.setData(orderFromVC.toDict)
    }
    
    func updateStateToBooked(documentId: String) {
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders").document(documentId).updateData(["orderState": 1])
    }
    
    func updateStateToPickUp(documentId: String) {
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders").document(documentId).updateData(["orderState": 2])
    }
    
    func updateStateToDeliver(documentId: String) {
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders").document(documentId).updateData(["orderState": 3])
    }
}
