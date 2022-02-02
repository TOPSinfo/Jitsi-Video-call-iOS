//
//  RegisterViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import Foundation
import UIKit

final class RegisterViewModel {
    
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    var registerVCDelegate: RegisterUserVCDelegate?
    var firebaseAuthViewModelDelegate: FirebaseAuthViewModelDelegate?
    
    init() {
        self.registerVCDelegate = self
    }
    
}

extension RegisterViewModel : RegisterUserVCDelegate {
    
    
    //Upload user Image
    func uploadImage(fileData: Data?, fileName:String, type:MediaType) {
        
        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }
        
        firebaseViewModel.firebaseStorageManager.uploadImage(childPath: fileName, imageNeedstoUpload: fileData, type: type) { task,ref  in
            if task != nil {
                self.firebaseAuthViewModelDelegate?.didUploadUserImage?(task: task, reference: ref)
            } else {
                self.firebaseAuthViewModelDelegate?.error?(error: "fail to upload image", sign: false)
            }
        }


    }
    
    //Button click from cotroller and register user in databse
    func buttonClicked(userID:String, dic:[String:Any]) {
        
        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }
        
        firebaseViewModel.firebaseCloudFirestoreManager.registerUser(userID: userID, dic: dic) {
            self.firebaseAuthViewModelDelegate?.register?(true)
        } failure: { (error) in
            self.firebaseAuthViewModelDelegate?.error?(error: error, sign: false)
        }
        
    }
}
