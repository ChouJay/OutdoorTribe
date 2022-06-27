//
//  AccountManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import Foundation
import FirebaseFirestore

class AccountManager {
    static let shared = AccountManager()
    
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
}
