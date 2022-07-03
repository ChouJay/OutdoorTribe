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
    
    func retrieveLeasingOrder(userName: String, _ completion: @escaping ([Order]) -> Void) {
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders")
            .whereField("orderState", isGreaterThan: 2)
            .whereField("orderState", isLessThan: 5)
            .addSnapshotListener { querySnapShot, error in
            var orders = [Order]() // 不能放在retrieveRentOrder function內，要放在閉包一開始宣告，不然陣列不會被重置!
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    let order: Order?
                    do {
                        order = try document.data(as: Order.self, decoder: Firestore.Decoder())
                        guard let order = order else { return }
                        if order.lessor == userName {
                            orders.append(order)
                        }
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(orders)
            }
        }
    }

    func retrieveRentedOrder(userName: String, _ completion: @escaping ([Order]) -> Void) {
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders")
            .whereField("orderState", isGreaterThan: 2)
            .whereField("orderState", isLessThan: 5)
            .addSnapshotListener { querySnapShot, error in
            var orders = [Order]() // 不能放在retrieveRentOrder function內，要放在閉包一開始宣告，不然陣列不會被重置!
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    let order: Order?
                    do {
                        order = try document.data(as: Order.self, decoder: Firestore.Decoder())
                        guard let order = order else { return }
                        if order.renter == userName {
                            orders.append(order)
                        }
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(orders)
            }
        }
    }

    func retrieveBookedOrder(userName: String, _ completion: @escaping ([Order]) -> Void) {
       
        let firstoreDb = Firestore.firestore()
        // 還沒進行時間排序！！
        firstoreDb.collection("orders")
            .whereField("orderState", isLessThan: 3)
            .whereField("orderState", isGreaterThan: 0)
            .addSnapshotListener { querySnapShot, error in
            var orders = [Order]()
                print(querySnapShot?.documents.count)
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    let order: Order?
                    do {
                        order = try document.data(as: Order.self, decoder: Firestore.Decoder())
                        guard let order = order else { return }
                        print(order)
                        if order.renter == userName || order.lessor == userName {
                            orders.append(order)
                        }
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
    
    func updateStateToReturn(documentId: String) {
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders").document(documentId).updateData(["orderState": 4])
    }
    
    func updateStateToFinish(documentId: String) {
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("orders").document(documentId).updateData(["orderState": 5])
    }


}
