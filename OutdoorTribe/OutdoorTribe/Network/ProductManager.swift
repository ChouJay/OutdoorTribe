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
    
    func retrievePhotos(_ completion: @escaping ([QueryDocumentSnapshot]) -> ()) {
        var documents = [QueryDocumentSnapshot]()
        let db = Firestore.firestore()
        db.collection("image").getDocuments(source: .server) { querySnapShot, error in
            if error == nil && querySnapShot != nil {
                for document in querySnapShot!.documents {
                    documents.append(document)
                }
                completion(documents)
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
