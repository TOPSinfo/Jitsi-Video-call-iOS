//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 12/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

//MARK:- Firebase Auth custom protocol methods of view model
@objc protocol FirebaseAuthViewModelDelegate {
    @objc optional func didUploadUserImage(task:StorageUploadTask?, reference:StorageReference?)
    @objc optional func sendOTP() // with call after send OTP form firebase method
    @objc optional func verifyphone(_ verificationID:String) // will call on success of verifcationphone
    @objc optional func login(_ authResult: AuthDataResult?) // Will call on success of login
    @objc optional func checkAvalability(_ isRegisterd:Bool) // wil call afte user check query
    @objc optional func error(error: String, sign: Bool) //will call when firebase return error
    @objc optional func register(_ isRegister:Bool) //when user successfully registre
    @objc optional func didGetUserList(_ userlist:Array<Any>) // call when user will get list from firestore
    @objc optional func didGetGroupList(_ userlist:Array<Any>)
}


final class LoginViewModel {
    
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel() //Object of fiebaseAthView model
    var addMobileViewControllerDelegate: addMobileViewControllerDelegate? // Object of controller protocol to access methos
    var firebaseAuthViewModelDelegate: FirebaseAuthViewModelDelegate? // instance of firebase auth delegate protocol
    
    init() {
        self.addMobileViewControllerDelegate = self
    }
    
}

extension LoginViewModel: addMobileViewControllerDelegate {
    //Button click of add Model controller
    func buttonClicked(phone: String) {
        self.firebaseAuthViewModelDelegate?.sendOTP!()
    }
    
}
