//
//  FirebaseCloudFirestoreManager.swift
//  SampleCodeiOS
//
//  Created by Tops on 01/10/21.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth

enum MessageStatus {
    case image
    case video
}

class FirebaseCloudFirestoreManager {

    // MARK: - firestore database object
    var dbf: Firestore = Firestore.firestore()
    // MARK: - check user is registred or not
    func checkUserAvailableQuery(uid: String) -> Query {
        let userRef = dbf.collection("USER")
        return userRef.whereField("uid", isEqualTo: uid)
    }
    // MARK: - register User using basic detail
    func registerUser(userID: String, dic: [String: Any], completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)) {
        dbf.collection("USER").document(userID).setData(dic) { (error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                completion()
            }
        }
    }

    func createGroup(groupID: String, dic: [String: Any], completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)) {
        dbf.collection("GroupDetail").document(groupID).setData(dic) { error in
            if let error = error{
                failure(error.localizedDescription)
            } else {
                completion()
            }
        }
    }

    // MARK: - get current user detail using user_id
    func getUserDetail(userID: String, completion: @escaping((_ arrayUsers: SignupUserData) -> Void), failure: @escaping((_ error: String) -> Void)) {
        dbf.collection("USER").document(userID).getDocument(completion: { (documentSnapshot, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                        if let document = documentSnapshot.data() {
                            let data = SignupUserData.init(fromDictionary: document)
                            completion(data)
                        } else {
                            completion(SignupUserData())
                        }
                } else {
                    failure("")
                }
            }
        })
    }

    // MARK: - Get all user who are registred in except self
    func getAlluser(completion: @escaping((_ arrayUsers: [SignupUserData]) -> Void), failure: @escaping((_ error: String) -> Void)) {
        let uid = Auth.auth().currentUser?.uid ?? "0"
        Singleton.userListner = dbf.collection("USER").whereField("uid", isNotEqualTo: uid).addSnapshotListener { querySnapshot, error  in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                var array = [SignupUserData]()
                if let documents = querySnapshot?.documents, documents.count > 0 {
                    // This is the on change listner
                    querySnapshot!.documentChanges.forEach({ (diff) in
                        if diff.type == .added {
                            let user = SignupUserData.init(fromDictionary: diff.document.data())
                            user.type = .added
                            array.append(user)
                        } else if diff.type == .modified {
                            let user = SignupUserData.init(fromDictionary: diff.document.data())
                            user.type = .modified
                            array.append(user)
                        } else if diff.type == .removed {
                            let user = SignupUserData.init(fromDictionary: diff.document.data())
                            user.type = .removed
                            array.append(user)
                        }
                    })
                }
                completion(array)
            }
        }
    }

    // MARK: - Get all user who are registred in except self
    func getGroupUser(completion: @escaping((_ arrayUsers: [SignupUserData]) -> Void), failure: @escaping((_ error: String) -> Void)) {
        _ = Auth.auth().currentUser?.uid ?? "0"
        Singleton.groupListner = self.dbf.collection("GroupDetail").whereField("members", arrayContainsAny: [AppDelegate.standard.objCurrentUser.uid]).addSnapshotListener { querySnapshot, error  in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                var arrayGrouop = [SignupUserData]()
                if let documents = querySnapshot?.documents, documents.count > 0 {
                    // This is the on change listner
                    querySnapshot!.documentChanges.forEach({ (diff) in
                        if diff.type == .added {
                            let user = SignupUserData.init(fromDictionaryGroup: diff.document.data())
                            user.type = .added
                            arrayGrouop.append(user)
                        } else if diff.type == .modified {
                            let user = SignupUserData.init(fromDictionaryGroup: diff.document.data())
                            user.type = .modified
                            arrayGrouop.append(user)
                        } else if diff.type == .removed {
                            let user = SignupUserData.init(fromDictionaryGroup: diff.document.data())
                            user.type = .removed
                            arrayGrouop.append(user)
                        }
                    })
                }
                completion(arrayGrouop)
            }
        }
    }

    // MARK: - TO Get conversation between two users with realtime update lithner
    func getConversation(toUserid: String, isForGroup: Bool, completion: @escaping((_ arrayUsers: [MessageClass]) -> Void), failure: @escaping((_ error: String) -> Void)) {
        let cid = Auth.auth().currentUser?.uid ?? ""
        var docid = Singleton.sharedSingleton.getOneToOneID(senderID: cid, receiverID: toUserid)
        if isForGroup == true {
           docid = toUserid
        }
        Singleton.converstaonListner = dbf.collection("Messages").document(docid).collection("message").order(by: "timestamp", descending: false).addSnapshotListener(includeMetadataChanges: false) { querySnapshot, error in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                var messages = [MessageClass]()
                if let documents = querySnapshot?.documents, documents.count > 0 {

                    // This is the on change listner
                    querySnapshot!.documentChanges.forEach({ (diff) in
                        if diff.type == .added {
                            let message = MessageClass.init(fromDictionary: diff.document.data())
                            message.type = .added
                            message.docId = diff.document.documentID
                            messages.append(message)
                        } else if diff.type == .modified {
                            let message = MessageClass.init(fromDictionary: diff.document.data())
                            message.type = .modified
                            message.docId = diff.document.documentID
                            messages.append(message)
                        } else if diff.type == .removed {
                            let message = MessageClass.init(fromDictionary: diff.document.data())
                            message.type = .removed
                            message.docId = diff.document.documentID
                            messages.append(message)
                        }
                    })
                }
                let batch = Firestore.firestore().batch()
                let filtered = messages.filter({$0.senderId == toUserid})
                filtered.forEach { messaes in
                    if messaes.status == Singleton.MessageStatus.SEND {
                        let docRef = Firestore.firestore().collection("Messages").document(docid).collection("message").document(messaes.docId)
                        batch.updateData(["status": Singleton.MessageStatus.READ], forDocument: docRef)
                    }
                }
                batch.commit { error in
                    if error == nil {
                        print("Updated all records")
                    }
                 }
                completion(messages)
            }
        }
    }

    // MARK: - TO send message - one to one chat
    func sendMessage(conversationID: String, messageID: String, dic: [String: Any], completion: @escaping((_ arrayUsers: MessageClass) -> Void), failure: @escaping((_ error: String) -> Void)) {
        print("docID:-", conversationID)
        print("messageID", messageID)
        dbf.collection("Messages").document(conversationID).collection("message").document(messageID).setData(dic) { (error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                let message = MessageClass.init(fromDictionary: dic)
                completion(message)
            }
        }
    }

    func generateRoomIdForJetsi(arr: [String]) -> String {
        var str = ""
        for item in arr {
            str += item
        }
        return "TOPS" + str
    }

    // MARK: - Add Group Call Details
    func addGroupCall(arr: [SignupUserData], completion: @escaping((_ error: String) -> Void), failure: @escaping((_ error: String) -> Void)) {
        let objCurrentUser = Auth.auth().currentUser
        var arrUserid = arr.map({ $0.uid })
        arrUserid = arrUserid.map({ $0 + "___InActive" })
        arrUserid.append((objCurrentUser?.uid ?? "") + "___Active")
        arrUserid.sort { $0 < $1 }
        var dict: [String: Any] = [:]
        dict["userIds"] = arrUserid
        dict["CallStatus"] = "Active"
        dict["HostId"] = objCurrentUser?.uid ?? ""
        dict["HostName"] = AppDelegate.standard.objCurrentUser.fullName
        let groupCall = dbf.collection("GroupCall").document()
        let gid = groupCall.documentID
        groupCall.setData(dict)
        completion(gid)
    }

    // MARK: - Add Group Call Details
    func addGroupCallForDetailPage(arr: [String], completion: @escaping((_ error: String) -> Void), failure: @escaping((_ error: String) -> Void)) {
        let objCurrentUser = Auth.auth().currentUser
        var arrUserid = arr
        arrUserid = arrUserid.map({ $0 + "___InActive" })
        arrUserid.append((objCurrentUser?.uid ?? "") + "___Active")
        arrUserid.sort { $0 < $1 }
        var dict: [String: Any] = [:]
        dict["userIds"] = arrUserid
        dict["CallStatus"] = "Active"
        dict["HostId"] = objCurrentUser?.uid ?? ""
        dict["HostName"] = AppDelegate.standard.objCurrentUser.fullName
        let groupCall = dbf.collection("GroupCall").document()
        let gid = groupCall.documentID
        groupCall.setData(dict)
        completion(gid)
    }

    // MARK: - Add Group Call Details
    func setGroupCallListner(userID: String, completion: @escaping((_ roomId: String) -> Void), failure: @escaping((_ error: String) -> Void)) {
        dbf.collection("GroupCall").whereField("userIds", arrayContainsAny: [userID + "___Active", userID + "___InActive"])
            .whereField("CallStatus", isEqualTo: "Active").addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                if let documents = querySnapshot?.documents, documents.count > 0 {
                    print(documents)
                    // This is the on change listner
                    querySnapshot!.documentChanges.forEach({ (diff) in
                        print(diff.document.data())
                        if diff.type == .added {
                            print(diff.document.documentID)
                            let dict = diff.document.data()
                            AppDelegate.standard.arrForActiveCallList.append(ActiveCallList(fromDictionary: dict, dId: diff.document.documentID))
                            completion(diff.document.documentID)
                        } else if diff.type == .modified {
                            print("modify")
                        } else if diff.type == .removed {
                            print("removed")
                        }
                    })
                }
            }
        }

        dbf.collection("GroupCall").whereField("userIds", arrayContainsAny:[userID + "___Active", userID + "___InActive"])
            .whereField("CallStatus", isEqualTo: "InActive").addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                if let documents = querySnapshot?.documents, documents.count > 0 {
                    print(documents)
                    querySnapshot!.documentChanges.forEach({ (diff) in
                        print(diff.document.data())
                        for item in AppDelegate.standard.arrForActiveCallList where item.documentId == diff.document.documentID {
                            if let row = AppDelegate.standard.arrForActiveCallList.firstIndex(where: {$0.documentId == diff.document.documentID}) {
                                AppDelegate.standard.arrForActiveCallList.remove(at: row)
                            }
                        }
                    })
                }
            }
        }
    }

    // MARK: - Change group/one to one call status
    func changeCallStatus(_ roomId: String, isActive: Bool) {
        let docRef = dbf
            .collection("GroupCall")
            .document(roomId)

        // Get data
        docRef.getDocument { (document, _) in
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            var dataDescription = document.data()
            if var array = dataDescription?["userIds"] as? [String] {
                if isActive {
                    if let row = array.firstIndex(where: {$0 == ((Auth.auth().currentUser?.uid ?? "") + "___InActive")}) {
                           array[row] = ((Auth.auth().currentUser?.uid ?? "") + "___Active")
                    }
                } else {
                    if let row = array.firstIndex(where: {$0 == ((Auth.auth().currentUser?.uid ?? "") + "___Active")}) {
                           array[row] = ((Auth.auth().currentUser?.uid ?? "") + "___InActive")
                    }
                }
                dataDescription?["userIds"] = array
                var isAllInactive: Bool = true
                for str in array {
                    if str.contains("___Active") {
                        isAllInactive = false
                    }
                }
                if isAllInactive {
                    dataDescription?["CallStatus"] = "InActive"
                }
            }
            docRef.setData(dataDescription ?? [:])
            print(dataDescription ?? "")
        }
    }

    func doOnlineOffline(_ isOnline: Bool, userID: String) {
        dbf.collection("USER").document(userID).updateData(["isOnline": isOnline]) { _ in
        }
    }

    func checkUserIsOnline(userID: String, completion: @escaping((_ isOnline: Bool) -> Void), failure: @escaping((_ error: String) -> Void)) {
        Singleton.onlineOfflineLisnter = dbf.collection("USER").whereField("uid", isEqualTo: userID).addSnapshotListener { querySnapshot, error  in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                var array = [SignupUserData]()
                if let documents = querySnapshot?.documents, documents.count > 0 {
                    // This is the on change listner
                    querySnapshot!.documentChanges.forEach({ (diff) in
                        if diff.type == .added {
                            let user = SignupUserData.init(fromDictionary: diff.document.data())
                            array.append(user)
                        } else if diff.type == .modified {
                            let user = SignupUserData.init(fromDictionary: diff.document.data())
                            array.append(user)
                        } else if diff.type == .removed {
                            let user = SignupUserData.init(fromDictionary: diff.document.data())
                            array.append(user)
                        }
                    })
                }

                if array.count > 0 {
                    completion(array[0].isOnline)
                } else {
                    completion(false)
                }
            }
        }
    }
 
    // MARK: - Change group/one to one call status
    func getCurrentUserDetails(_ userId: String) {
        let docRef = dbf
            .collection("USER")
            .document(userId)
        // Get data
        docRef.getDocument { (document, _) in
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            let dataDescription = document.data()
            AppDelegate.standard.objCurrentUser = SignupUserData(fromDictionary: dataDescription ?? [:])
        }
    }
}
