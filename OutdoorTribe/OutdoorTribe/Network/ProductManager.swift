//
//  ProductManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ProductManager {
    static let shared = ProductManager()
    
    func deleteProductWithUser(userID: String) {
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("product").getDocuments(source: .server) { querySnapShot, err in
            if err == nil {
                guard let querySnapShot = querySnapShot else { return }
                for document in querySnapShot.documents {
                    print(document.data())
                    if let productRenterID = document.data()["renterUid"] as? String {
                        if userID == productRenterID {
                            document.reference.delete()
                        }
                    }
                }
            } else {
                print(err)
            }
        }
    }
    
    func classifyPostedProduct(keyWord: String, _ completion: @escaping ([Product]) -> Void) {
        var products = [Product]()
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("product")
            .whereField("classification", isEqualTo: keyWord)
            .getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    let product: Product?
                    do {
                        product = try document.data(as: Product.self, decoder: Firestore.Decoder())
                        guard let product = product else { return }
                        products.append(product)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(products)
            }
        }
    }
    
    func searchPostedProduct(keyWord: String, _ completion: @escaping ([Product]) -> Void) {
        var products = [Product]()
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("product")
            .whereField("title", isGreaterThanOrEqualTo: keyWord)
            .whereField("title", isLessThan: keyWord + "z")
            .getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    let product: Product?
                    do {
                        product = try document.data(as: Product.self, decoder: Firestore.Decoder())
                        guard let product = product else { return }
                        products.append(product)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(products)
            }
        }
    }
    
    func retrievePostedProduct(_ completion: @escaping ([Product]) -> Void) {
        var documents = [QueryDocumentSnapshot]()
        var products = [Product]()
        let firstoreDb = Firestore.firestore()
        firstoreDb.collection("product").getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    documents.append(document)
                    let product: Product?
                    do {
                        product = try document.data(as: Product.self, decoder: Firestore.Decoder())
                        guard let product = product else { return }
                        products.append(product)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completion(products)
            }
        }
//        return retrieveImages
    }
    
    func postProduct(withProduct: Product) {
        let fireStoreDb = Firestore.firestore()
        fireStoreDb.collection("product").document().setData(withProduct.toDict)
    }
    
    func postProductByUser(withProduct: Product, user: FirebaseAuth.User) {
        let fireStoreDb = Firestore.firestore()
        fireStoreDb.collection("userPosts").document(user.uid).collection("products").document().setData(withProduct.toDict)
    }
    
    func upload(uploadedPhotos: [UIImage], productFromVC: Product) {
        let group: DispatchGroup = DispatchGroup()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "images/\(UUID().uuidString).jpg"
        var endPoint = 0
        var paths = [String]()
        for image in uploadedPhotos {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            let fileRef = storageRef.child(path + String(endPoint))
            group.enter()
            fileRef.putData(imageData, metadata: nil) { storageMetadata, error in
                if error == nil && storageMetadata != nil {
                    fileRef.downloadURL { url, error in
                        guard let downloadUrl = url else {
                            print(error)
                            return
                        }
                        let urlString = downloadUrl.absoluteString
                        paths.append(urlString)
                        group.leave()
                    }
                }
            }
            endPoint += 1
        }
        
        group.notify(queue: DispatchQueue.main) { 
            guard paths.isEmpty == false else { return }
            var product = productFromVC
            product.photoUrl = paths
            let firebaseAuth = Auth.auth()
            guard let currentUser = firebaseAuth.currentUser else { return }
            ProductManager.shared.postProduct(withProduct: product)
            ProductManager.shared.postProductByUser(withProduct: product, user: currentUser)
        }
    }
}
