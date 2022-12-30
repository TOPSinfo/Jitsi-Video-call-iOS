//
//  CreateGroupModel.swift
//  Firebase Chat iOS
//
//  Created by Tops on 22/10/21.
//

import Foundation
import FirebaseStorage

@objc protocol FirebaseCreateGroupViewModelDelegate {
    @objc optional func didUploadUserImage(task: StorageUploadTask?, reference: StorageReference?)
    @objc optional func groupCreated(_ isRegister: Bool)
    @objc optional func error(error: String, sign: Bool)
}

final class CreateGroupViewModel {

    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    weak var createGroupVCDelegate: CreateGroupVCDelegate?
    weak var firebaseCreateGroupViewModelDelegate: FirebaseCreateGroupViewModelDelegate?

    init() {
        self.createGroupVCDelegate = self
    }

}

extension CreateGroupViewModel: CreateGroupVCDelegate {

    func createGroup(groupID: String, dic: [String: Any]) {
        guard Reachability.isConnectedToNetwork() else {
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }

        firebaseViewModel.firebaseCloudFirestoreManager.createGroup(groupID: groupID, dic: dic) {
            self.firebaseCreateGroupViewModelDelegate?.groupCreated!(true)
        } failure: { error in
            self.firebaseCreateGroupViewModelDelegate?.error?(error: error, sign: false)
        }
    }

    // MARK: Upload user Image
    func uploadImage(fileData: Data?, fileName: String, type: MediaType) {

        guard Reachability.isConnectedToNetwork() else {
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }

        firebaseViewModel.firebaseStorageManager.uploadImage(childPath: fileName,
                                                             imageNeedstoUpload: fileData,
                                                             type: type) { task, ref  in
            if task != nil {
                self.firebaseCreateGroupViewModelDelegate?.didUploadUserImage?(task: task, reference: ref)
            } else {
                self.firebaseCreateGroupViewModelDelegate?.error?(error: "fail to upload image", sign: false)
            }
        }
    }
}
