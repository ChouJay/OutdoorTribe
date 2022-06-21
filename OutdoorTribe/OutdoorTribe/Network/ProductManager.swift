//
//  ProductManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class ProductManager {
    static let shared = ProductManager()
    
    func retrievePostedProduct(_ completion: @escaping ([Product]) -> ()) {
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
    func upload() {
        let firstoreDb = Firestore.firestore()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let path = "images/\(UUID().uuidString).jpg"
        var endPoint = 0
        var paths = [String]()
        
//            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
//            let fileRef = storageRef.child(path + String(endPoint))
//            let uploadTask = fileRef.putData(imageData, metadata: nil) { storageMetadata, error in
//                if error == nil && storageMetadata != nil {
//                    paths.append(path + String(endPoint))
//                    print(paths)
                    
//                    firstoreDb.collection("image").document("hhh").setData(["url": FieldValue.arrayUnion([path + String(endPoint)])])
//                }
//            }
    }
}
