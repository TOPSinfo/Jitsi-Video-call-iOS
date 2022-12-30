//
//  FirebaseStorageManager.swift
//  Firebase Chat iOS
//
//  Created by Tops on 11/10/21.
//

import Foundation
import FirebaseStorage

enum MediaType {
    case image
    case video
}

struct ChildPath {
    static let userProfileImage: String = "/images/users/"
    static let chatImage: String = "/images/chat/"
    static let chatVideo: String = "/videos/chat/"
}

class FirebaseStorageManager {

    // object of storage reference
    let storage = Storage.storage().reference()

    init() {

    }

    func uploadVideo(_ files: [(filename: String, file: Data, type: MediaType)],
                     completion: @escaping (_ url: String?) -> Void) {
        Singleton.sharedSingleton.showLoder()
    }
    // MARK: Upload image to firebase storage
    func uploadImage(childPath: String, imageNeedstoUpload: Data?, type: MediaType,
                     completion: @escaping (_ uploadtask: StorageUploadTask?, _ reference: StorageReference?) -> Void) {
        
        let storageRef = Storage.storage().reference().child(childPath)
        if let uploadData = imageNeedstoUpload {

            let metadata = StorageMetadata()
            
            switch type {
            case .image:
                metadata.contentType = "image/jpeg"
            case .video:
                metadata.contentType = "video/mp4"
            }

            let uploadTask = storageRef.putData(uploadData, metadata: metadata)
            completion(uploadTask, storageRef)
        }
    }
}
