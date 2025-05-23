//
//  UserListViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import Foundation

final class UserListViewModel {

    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    weak var userListVCDelegate: UserListVCDelegate?
    weak var firebaseAuthViewModelDelegate: FirebaseAuthViewModelDelegate?

    init() {
        self.userListVCDelegate = self
    }

}

extension UserListViewModel: UserListVCDelegate {
    // MARK: will get user list from firestore and send back to controller to list
    func getUserList() {

        guard Reachability.isConnectedToNetwork() else {
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }

        Singleton.sharedSingleton.showLoder()
        firebaseViewModel.firebaseCloudFirestoreManager.getAlluser { arrayOfUser in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.didGetUserList?(arrayOfUser)
        } failure: { (error) in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.error?(error: error, sign: false)
        }
    }

    func getGroupList() {

        guard Reachability.isConnectedToNetwork() else {
            Singleton.sharedSingleton.showToast(message: "Please check your internet connection")
            return
        }

        Singleton.sharedSingleton.showLoder()
        firebaseViewModel.firebaseCloudFirestoreManager.getGroupUser { arrayOfUser in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.didGetGroupList?(arrayOfUser)
        } failure: { (error) in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.error?(error: error, sign: false)
        }
    }
}
