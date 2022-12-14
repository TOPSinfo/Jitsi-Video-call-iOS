//
//  OTPViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import Foundation
import FirebaseFirestore
import Firebase
import CodableFirebase

final class OTPViewModel {
    
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    var OTPViewControllerDelegate: OTPViewControllerDelegate?
    var firebaseAuthViewModelDelegate: FirebaseAuthViewModelDelegate?
    
    init() {
        self.OTPViewControllerDelegate = self
    }
    
}

extension OTPViewModel : OTPViewControllerDelegate {
    
    // MARK: get verification id from firebase and send to controller
    func verifyPhone(phone: String) {
        
        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }
        
        Singleton.sharedSingleton.showLoder()
        firebaseViewModel.verifyPhone(phone: phone) { (verificationId) in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.verifyphone?(verificationId)
        } failure: { (error) in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.error?(error: error, sign: false)
        }
    }
    
    // MARK: get user credential from controller send to firestore and after login again send user object to controller
    func buttonClicked(verificationId: String, code: String) {
        
        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }
        
        Singleton.sharedSingleton.showLoder()
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: code)
        
        firebaseViewModel.login(credential: credential) { (result) in
            self.firebaseAuthViewModelDelegate?.login?(result)
            Singleton.sharedSingleton.hideLoader()
        } failure: { (error) in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.error!(error: error, sign: true)
        }
    }
     
    // MARK: will check user in database and send back bool value
    func checkUserAvailability(userID: String) {
        
        guard Reachability.isConnectedToNetwork() else{
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }
        
        Singleton.sharedSingleton.showLoder()
        
        firebaseViewModel.firebaseCloudFirestoreManager.checkUserAvailableQuery(uid: userID).getDocuments { (documents, err) in
            Singleton.sharedSingleton.hideLoader()
            if let err = err {
                self.firebaseAuthViewModelDelegate?.error!(error: err.localizedDescription, sign: true)
            } else {
                if ((documents?.documents.count)! > 0){
                    
                    for _ in documents!.documents {
                        self.firebaseAuthViewModelDelegate?.checkAvalability?(true)
                    }
                } else {
                    self.firebaseAuthViewModelDelegate?.checkAvalability?(false)
                }
            }
        }
    }
        
}
