//
//  FirebaseAuthManager.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseAuthManager {

    init() {
    }

    // MARK: - verify phone number and get verification id
    func verifyPhoneNumber(phoneNumber: String,
                           completion: @escaping((_ verificationID: String, _ error: Error?) -> Void)) {
        Auth.auth().settings!.isAppVerificationDisabledForTesting = true
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
              if let error = error {
                completion("", error)
                return
              }
            completion(verificationID ?? "", error)
        }
    }

    // MARK: - Login using phone credential
    func login(credential: PhoneAuthCredential,
               completion: @escaping((_ authResult: AuthDataResult?, _ error: Error?) -> Void)) {
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            completion(user, error)
        })
    }

    // MARK: - Logout from firebase session
    func signOut(completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        do {
            try Auth.auth().signOut()
            completion()
        } catch {
            failure(error.localizedDescription)
        }
    }
}
