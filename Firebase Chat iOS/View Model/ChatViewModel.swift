//
//  ChatViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import Foundation
import FirebaseStorage

@objc protocol FirebaseChatViewModelDelegate {
    @objc optional func didUploadMedia(_ url: StorageReference?, task: StorageUploadTask?, type: Any)
    @objc optional func didUploadVideo(_ imageRef: StorageReference?,
                                       imageTask: StorageUploadTask?,
                                       videoRef: StorageReference?, videoTask: StorageUploadTask?)
    @objc optional func getMessages(_ arrayMessage: Array<Any>)
    @objc optional func didSendMessage(_ message: Any)
    @objc optional func error(error: String, sign: Bool)
    @objc optional func didCheck(_ isOnline: Bool)
}

final class ChatViewModel {

    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    weak var chatVCDelegate: ChatVCDelegate?
    weak var firebasechatViewModelDelegate: FirebaseChatViewModelDelegate?

    init() {
        self.chatVCDelegate = self
    }
}

extension ChatViewModel: ChatVCDelegate {

    func checkUserisOnline(_ userID: String) {
        guard Reachability.isConnectedToNetwork() else {
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }
        
        firebaseViewModel.firebaseCloudFirestoreManager.checkUserIsOnline(userID: userID) { result in
            
            self.firebasechatViewModelDelegate?.didCheck?(result)
            
        } failure: { error in
            Singleton.sharedSingleton.showToast(message: error)
        }
    }
    
    func uploadVideo(_ files: [(filename: String, file: Data, type: MediaType)]) {
        
        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }
        
        Singleton.sharedSingleton.showLoder()
        var imageTask: StorageUploadTask?
        var videoTask: StorageUploadTask?
        var imageRef: StorageReference?
        var videoRef: StorageReference?
        let group = DispatchGroup()
        
        for file in files {
            group.enter()
            let fbm = firebaseViewModel.firebaseStorageManager
            fbm.uploadImage(childPath: file.filename,
                            imageNeedstoUpload: file.file, type: file.type) { task, reference  in
                if let ref = reference {
                    print(ref.fullPath)
                    if ref.fullPath.contains(".jpeg") {
                        imageTask = task
                        imageRef = reference
                    } else {
                        videoTask = task
                        videoRef = reference
                    }
                    DispatchQueue.main.async {
                        group.leave()
                    }
                } else {
                    DispatchQueue.main.async {
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            Singleton.sharedSingleton.hideLoader()
            if videoTask == nil {
                self.firebasechatViewModelDelegate?.error?(error: "Video upload fail", sign: false)
            } else {
                self.firebasechatViewModelDelegate?.didUploadVideo?(imageRef,
                                                                    imageTask: imageTask,
                                                                    videoRef: videoRef,
                                                                    videoTask: videoTask)
            }
        }
    }

    func uploadMediea(_ filename: String, file: Data, type: MediaType) {

        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }

        Singleton.sharedSingleton.showLoder()
        firebaseViewModel.firebaseStorageManager.uploadImage(childPath: filename,
                                                             imageNeedstoUpload: file, type: type) { task,url  in
            Singleton.sharedSingleton.hideLoader()

            if task != nil {
                self.firebasechatViewModelDelegate?.didUploadMedia?(url!, task: task, type: type)
            } else {
                self.firebasechatViewModelDelegate?.error?(error: "fail to upload image", sign: false)
            }
        }
    }

    // MARK: will send message to reciever using IDs and get revert to controller
    func sendMessage(conversationID: String, messageID: String, dic: [String : Any]) {

        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }

        firebaseViewModel.firebaseCloudFirestoreManager.sendMessage(conversationID: conversationID,
                                                                    messageID: messageID, dic: dic) { message in
            self.firebasechatViewModelDelegate?.didSendMessage?(message)
        } failure: { error in
            self.firebasechatViewModelDelegate?.error?(error: error, sign: true)
        }
    }

    // MARK: Will get message list between two users  and send back to controller
    func getMessageList(_ touserID: String, isForGroup: Bool) {
        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }

        Singleton.sharedSingleton.showLoder()
        firebaseViewModel.firebaseCloudFirestoreManager.getConversation(toUserid: touserID,
                                                                        isForGroup: isForGroup) { (messases) in
            self.firebasechatViewModelDelegate?.getMessages?(messases)
            Singleton.sharedSingleton.hideLoader()
        } failure: { (error) in
            self.firebasechatViewModelDelegate?.error?(error: error, sign: false)
            Singleton.sharedSingleton.hideLoader()
        }
    }
}
