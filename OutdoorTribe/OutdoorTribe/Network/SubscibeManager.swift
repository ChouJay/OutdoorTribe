//
//  SubscibeManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/29.
//

import Foundation
import FirebaseFirestore

class SubscribeManager {
    static let shared = SubscribeManager()
    
    func deleteOthersSubscriptionWithUser(userID: String) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("subscription").getDocuments(source: .server, completion: { querySnapShot, err in
            if err == nil {
                guard let querySnapShot = querySnapShot else { return }
                for document in querySnapShot.documents {
                    print(document)
                    document.reference.collection("otherUsers").document(userID).delete()
                }
            } else {
               print(err)
            }
        })
    }
    
    func loadingSubscriber(currentUserID: String, completion: @escaping ([Account]) -> Void) {
        let firestoreDB = Firestore.firestore()
        var accounts = [Account]()
        firestoreDB.collection("subscription").document(currentUserID)
            .collection("otherUsers").getDocuments(source: .server) { querySnapshot, error in
            if error == nil && querySnapshot != nil {
                guard let querySnapshot = querySnapshot else { return }
                for document in querySnapshot.documents {
                    do {
                        var account: Account?
                        account = try document.data(as: Account.self, decoder: Firestore.Decoder())
                        guard let account = account else { return }
                        accounts.append(account)
                    } catch {
                        print(error)
                    }
                }
                completion(accounts)
            }
        }
    }
    
    func recallFollow(currentUserID: String, otherUser: Account, completion: @escaping () -> Void) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("subscription")
            .document(currentUserID)
            .collection("otherUsers")
            .document(otherUser.userID).delete { error in
            if error == nil {
                completion()
            } else {
                print(error)
            }
        }
        firestoreDB.collection("users").document(otherUser.userID).updateData(["followerCount": FieldValue.increment(Int64(-1))])
    }
    
    func followUser(currentUserID: String, otherUser: Account) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("subscription")
            .document(currentUserID)
            .collection("otherUsers")
            .document(otherUser.userID)
            .setData(otherUser.toDict)
        
        firestoreDB.collection("subscription")
            .document(currentUserID)
            .setData(["toBeQuery": "ok"])
        
        // user count add 1
        firestoreDB.collection("users")
            .document(otherUser.userID)
            .updateData(["followerCount": FieldValue.increment(Int64(1))])
    }
}
