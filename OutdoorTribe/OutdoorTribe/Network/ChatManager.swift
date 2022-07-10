//
//  ChatManager.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/23.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class ChatManager {
    static let shared = ChatManager()
    
    func deleteChatRoomByUser(userID: String) {
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("chatRoom").getDocuments(source: .server) { querySnapShot, err in
            if err == nil {
                guard let querySnapShot = querySnapShot else { return }
                for document in querySnapShot.documents {
                    if let chaterOneUid = document.data()["chaterOneUid"] as? String,
                       let chaterTwoUid = document.data()["chaterTwoUid"] as? String {
                        print(chaterOneUid)
                        print(chaterTwoUid)
                        if userID == chaterOneUid || userID == chaterTwoUid {
                            document.reference.delete()
                        }
                    }
                }
            } else {
                print(err)
            }
        }
    }
    
    func updateChatRoomLastMessageIfSendPhoto(in roomID: String) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("chatRoom").document(roomID).updateData(["lastMessage": "send a photo"])
        firestoreDB.collection("chatRoom").document(roomID).updateData(["lastDate": Date()])
    }
    
    func updateChatRoomLastMessage(in roomID: String, by lastMessage: String) {
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("chatRoom").document(roomID).updateData(["lastMessage": lastMessage])
        firestoreDB.collection("chatRoom").document(roomID).updateData(["lastDate": Date()])
    }
    
    func createChatRoomIfNeed(chatRoom: ChatRoom,
                              chaterOne: String,
                              chaterTwo: String,
                              completion: @escaping (ChatRoom) -> Void) {
        print(chatRoom)
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("chatRoom")
            .whereField("users", arrayContainsAny: [chaterOne, chaterTwo])
            .getDocuments(source: .server) { querySnapShot, error in
            if error == nil {
                if querySnapShot?.documents.count == 0 {
                    print("set chat collection!")
                    self.createChatRoom(create: chatRoom)
                    completion(chatRoom)
                } else {
                    guard let querySnapShot = querySnapShot else { return }
                    for document in querySnapShot.documents {
                        let set: Set<String> = [chaterOne, chaterTwo]
                        guard let array = document.data()["users"] as? [String] else { return }
                        print(array)
                        let set2 = Set(array)
                        if set == set2 {
                            print(document.documentID)
                            var existChatRoom: ChatRoom?
                            do {
                                print("chat zoom exist")
                                existChatRoom = try document.data(as: ChatRoom.self, decoder: Firestore.Decoder())
                                guard let existChatRoom = existChatRoom else { return }
                                completion(existChatRoom)
                                return
                            } catch {
                                print("decode failure: \(error)")
                            }
                        }
                    }
                    print("set chat room when there is no exidted!")
                    self.createChatRoom(create: chatRoom)
                    completion(chatRoom)
                }
            } else {
                print(error)
            }
        }
    }
    
    func createChatRoom(create chatRoom: ChatRoom) {
        let firestoreDb = Firestore.firestore()
        let document = firestoreDb.collection("chatRoom").document(chatRoom.roomID)
        document.setData(chatRoom.toDict) { error in
            if error == nil {
                // push chat room VC
                
            } else {
                print("set data error: \(error)")
            }
        }
    }
    
    func createChat(in chatRoom: ChatRoom, put chatMessage: Message) {
        let firestoreDb = Firestore.firestore()
        let document = firestoreDb.collection("chat").document(chatRoom.roomID)
        document.collection("chatMessage").document().setData(chatMessage.toDict) { error in
            if error != nil {
                print(error)
            }
        }
    }
    
    func loadHistoryMessage(from chatRoom: ChatRoom, _ completionHandler: @escaping ([Message]) -> Void) {
        var chatMessages = [Message]()
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("chat").document(chatRoom.roomID).collection("chatMessage")
            .order(by: "date", descending: true).getDocuments(source: .server) { querySnapShot, error in
            if error == nil {
                guard let documents = querySnapShot?.documents else { return }
                for document in documents {
                    let message: Message?
                    do {
                        message = try document.data(as: Message.self, decoder: Firestore.Decoder())
                        guard let message = message else { return }
                        chatMessages.append(message)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completionHandler(chatMessages)
            } else {
                print(error)
            }
        }
    }
    
    func loadingChatRoom( userName: String,_ completionHandler: @escaping ([ChatRoom]) -> Void ) {
        var chatRooms = [ChatRoom]()
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("chatRoom")
            .whereField("users", arrayContains: userName)
            .getDocuments(source: .server) { querySnapShot, error in
            if error == nil {
                print(querySnapShot?.count)
                guard let documents = querySnapShot?.documents else { return }
                for document in documents {
                    let chatRoom: ChatRoom?
                    do {
                        chatRoom = try document.data(as: ChatRoom.self, decoder: Firestore.Decoder())
                        guard let chatRoom = chatRoom else { return }
                        print(chatRoom)
                        chatRooms.append(chatRoom)
                    } catch {
                        print("decode failure: \(error)")
                    }
                }
                completionHandler(chatRooms)
            } else {
                print(error)
            }
        }
    }
    
    func addChatRoomListener(to chatRoom: ChatRoom, _ completionHandler: @escaping ([Message]) -> Void) {
        var chatMessages = [Message]()
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("chat").document(chatRoom.roomID).collection("chatMessage")
            .order(by: "date", descending: false).addSnapshotListener { querySnapShot, error in
            chatMessages = []
            print("listen time")
            if error == nil {
                guard let querySnapShot = querySnapShot else { return }
                querySnapShot.documentChanges.forEach { diff in
                if diff.type == .added {
                    let message: Message?
                    do {
                        message = try diff.document.data(as: Message.self, decoder: Firestore.Decoder())
                        guard let message = message else { return }
                        print(message)
                        chatMessages.append(message)
                        
                    } catch {
                        print("decode failure: \(error)")
                    }
                    print("add chat: \(diff.document.data())")
                    }
                }
            } else {
                print(error)
            }
            completionHandler(chatMessages)
        }
    }

}
