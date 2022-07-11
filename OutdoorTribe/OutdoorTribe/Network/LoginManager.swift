//
//  LoginManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class LoginManager {
    static let shared = LoginManager()
    
    func nativeSignUp(email: String, password: String, name: String,
                      completion: @escaping (Result<String, Error>) -> Void) {
        let firebaseAuth = Auth.auth()
        firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                guard let user = authResult?.user else { return }
                // changeRequest to set currentUser name, when account signUp
                let changeRequest = firebaseAuth.currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = name
                changeRequest?.commitChanges(completion: { error in
                    print(error)
                })
                let account = Account(email: email,
                                      userID: user.uid,
                                      providerID: user.providerID,
                                      name: name,
                                      photo: "",
                                      totalScore: 0,
                                      ratingCount: 0,
                                      point: 3500,
                                      followerCount: 0)
                AccountManager.shared.storeRegistedAccount(account: account) { result in
                    switch result {
                    case let .success(string):
                        completion(.success(string))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            } else {
                guard let error = error else { return }
                completion(.failure(error))
            }
        }
    }
    
    func nativeSignIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let firebaseAuth = Auth.auth()
        firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            if error == nil {
                completion(.success("Login Success!"))
                print("success")
            } else {
                guard let error = error else {return}
                completion(.failure(error))
                print(error)
            }
        }
    }
}
