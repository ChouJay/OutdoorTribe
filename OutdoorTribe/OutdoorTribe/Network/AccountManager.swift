//
//  AccountManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class AccountManager {
    static let shared = AccountManager()
    
    func loadUserBlockList(byUserID: String) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("users")
            .document(byUserID)
            .collection("blockList")
            .getDocuments(source: .server) { querySnapShot, error in
                if error == nil {
                    print(querySnapShot)
                }
            }
    }
    
    func unBlockUser(byUserID: String, unBlockUser: Account) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("users")
            .document(byUserID)
            .collection("blockList")
            .document(unBlockUser.userID).delete()

    }
    
    func blockUser(byUserID: String, blockUser: Account) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("users")
            .document(byUserID)
            .collection("blockList")
            .document(blockUser.userID)
            .setData(blockUser.toDict) { error in
                if error == nil {
                    
                }
            }
    }
    
    func uploadUserPhoto(uploadedImage: UIImage, userID: String) {
        let group: DispatchGroup = DispatchGroup()
        let firestoreDB = Firestore.firestore()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "userPhoto/\(UUID().uuidString).jpg"
        var urlString = ""
        guard let imageData = uploadedImage.jpegData(compressionQuality: 0.7) else { return }
        let fileRef = storageRef.child(path)
        group.enter()
        fileRef.putData(imageData, metadata: nil) { storageMetadata, error in
            if error == nil && storageMetadata != nil {
                fileRef.downloadURL { url, error in
                    guard let downloadUrl = url else {
                        print(error)
                        return
                    }
                    urlString = downloadUrl.absoluteString
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            guard urlString != "" else { return }
            firestoreDB.collection("users").document(userID).updateData(["photo": urlString])
        }
    }
    
    func getUserPost(byUserID: String, completion: @escaping ([Product]) -> Void) {
        var products = [Product]()
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("userPosts")
            .document(byUserID)
            .collection("products")
            .getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                guard let querySnapShot = querySnapShot else { return }
                for document in querySnapShot.documents {
                    do {
                        var product: Product?
                        product = try document.data(as: Product.self, decoder: Firestore.Decoder())
                        guard let product = product else { return }
                        products.append(product)
                    } catch {
                        print(error)
                    }
                }
                completion(products)
            }
        }
    }
    
    func ratingUser(userID: String, score: Double) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("users").document(userID).updateData(["totalScore": FieldValue.increment(score)])
        firestoreDB.collection("users").document(userID).updateData(["ratingCount": FieldValue.increment(Int64(1))])
    }
    
    func storeRegistedAccount(account: Account, completion: @escaping (Result<String, Error>) -> Void) {
        let firstoreDB = Firestore.firestore()
        let document = firstoreDB.collection("users").document(account.userID)
        document.setData(account.toDict) { error in
            if error == nil {
                completion(.success("SignUp success!"))
            } else {
                guard let error = error else { return }
                completion(.failure(error))
            }
        }
    }
    
    func getUserInfo(by uid: String, completion: @escaping (Account) -> Void) {
        var userInfo: Account?
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("users").document(uid).getDocument(source: .server) { snapShot, error in
            if error == nil && snapShot != nil {
                do {
                    guard let snapShot = snapShot else { return }
                    userInfo = try snapShot.data(as: Account.self, decoder: Firestore.Decoder())
                    guard let userInfo = userInfo else { return }
                    completion(userInfo)
                } catch {
                    print("decode failure: \(error)")
                }
            }
        }
    }
    
    func getAllUserInfo(completion: @escaping ([Account]) -> Void) {
        var allUserInfo = [Account]()
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("users").getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                guard let querySnapShot = querySnapShot else { return }
                for document in querySnapShot.documents {
                    do {
                        let userInfo: Account?
                        userInfo = try document.data(as: Account.self, decoder: Firestore.Decoder())
                        guard let userInfo = userInfo else { return }
                        allUserInfo.append(userInfo)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(allUserInfo)
            }
        }
    }
}
