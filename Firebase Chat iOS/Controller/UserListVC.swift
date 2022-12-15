//
//  UserListVC.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import UIKit
import JitsiMeetSDK
import FirebaseAuth

class UserListCell: UITableViewCell {
    @IBOutlet weak var img_user:UIImageView!
    @IBOutlet weak var lbl_userName:UILabel!
    @IBOutlet weak var imgOnlineOffLine: UIImageView!
}

protocol UserListVCDelegate: AnyObject {
    func getUserList()
    func getGroupList()
}

class UserListVC: UIViewController {
    
    // MARK: - Variable
    let userViewModel: UserListViewModel = UserListViewModel()
    var userArray = [SignupUserData]()
    var selectedForGroupCall = [SignupUserData]()
    
    // MARK: - Outlet
    @IBOutlet weak var tbl_userList:UITableView!
    @IBOutlet weak var btn_logout:UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    
    var isFirstTime = true
    var isFirstTimeGroup = true
    fileprivate var jitsiMeetView: JitsiMeetView?
    
    var isMultipleSelection: Bool = false
    let currentUId = Auth.auth().currentUser?.uid ?? ""
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    
    var objJitsi: JitsiManager = JitsiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview delgate and datasource
        self.tbl_userList.delegate = self
        self.tbl_userList.dataSource = self
        btnCall.isHidden = true
        btnCreate.isHidden = true
        
        // Will call to get list of register user
        
        print(currentUId)
        Singleton.sharedSingleton.doOnlineOffline(isOnline: true)
        firebaseViewModel.firebaseCloudFirestoreManager.setGroupCallListner(userID: currentUId) { _ in
            
        } failure: { (_) in
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set delegate of auth view model
        isFirstTime = true
        isFirstTimeGroup = true
        userViewModel.userListVCDelegate?.getUserList()
        userViewModel.firebaseAuthViewModelDelegate = self
        isMultipleSelection = false
        selectedForGroupCall = []
        tbl_userList.reloadData()
        btnCall.isHidden = true
        btnCreate.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Singleton.userListner?.remove()
    }
    
    // MARK: - USer will logout from auth session and app
    @IBAction func btn_logout(_ sender:UIButton) {
        Singleton.sharedSingleton.doOnlineOffline(isOnline: false)
        userViewModel.firebaseViewModel.logautUser { (_) in
            Singleton.sharedSingleton.setNavigation()
        } failure: { (error) in
            Singleton.sharedSingleton.showToast(message: error)
        }
    }
    
    @IBAction func btnGroupCallClick(_ sender: Any) {
        if isMultipleSelection == true {
            isMultipleSelection = false
            selectedForGroupCall = []
            tbl_userList.reloadData()
            btnCall.isHidden = true
            btnCreate.isHidden = true
        } else {
            newCallAlert()
        }
    }
    
    @IBAction func btnChatGroup(_ sender:UIButton) {
        if isMultipleSelection == true {
            isMultipleSelection = false
            selectedForGroupCall = []
            tbl_userList.reloadData()
            btnCreate.isHidden = true
        } else {
            self.isMultipleSelection = true
            btnCreate.isHidden = false
        }
    }
    
    @IBAction func btnCreateClick(_ sender: Any) {
        if selectedForGroupCall.count > 1 {
            guard let vcCG = Singleton.sharedSingleton.getController(storyName: Singleton.StoryboardName.Main, controllerName: Singleton.ControllerName.CreateGroupVC) as? CreateGroupVC else { return }
            vcCG.selectedForGroupCall = self.selectedForGroupCall
            self.navigationController?.pushViewController(vcCG, animated: true)
        } else {
            let alert = UIAlertController(title: "", message: "Please select more than 2 user for group call", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCallClick(_ sender: Any) {
        if selectedForGroupCall.count > 1 {
            firebaseViewModel.firebaseCloudFirestoreManager.addGroupCall(arr: selectedForGroupCall) { (docId) in
                self.objJitsi.viewController = self
                self.objJitsi.openJetsiViewWithUser(roomid: docId)
            } failure: { (_) in
                
            }
        } else {
            let alert = UIAlertController(title: "", message: "Please select more than 2 user for group call", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func newCallAlert() {
        let alert = UIAlertController(title: "Please select a call", message: "", preferredStyle: .actionSheet)
        
        for item in AppDelegate.standard.arrForActiveCallList where item.userIds.count > 2 {
//            if item.userIds.count > 2 {
                alert.addAction(UIAlertAction(title: "Call From \(item.HostName)" , style: .default, handler: { _ in
                    self.objJitsi.viewController = self
                    self.objJitsi.openJetsiViewWithUser(roomid: item.documentId)
                }))
//            }
        }
        
        alert.addAction(UIAlertAction(title: "New Group Call", style: .default, handler: { _ in
            self.isMultipleSelection = true
            self.btnCall.isHidden = false
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    
    }
    
    deinit {
        Singleton.userListner?.remove()
    }
}
// MARK: - extended Firebase Auth view model protocol
extension UserListVC: FirebaseAuthViewModelDelegate {
    // MARK: Will show error.
    func error(error: String, sign: Bool) {
        
        if isFirstTimeGroup {
            userViewModel.userListVCDelegate?.getGroupList()
        }
        
        Singleton.sharedSingleton.showToast(message: error)
    }
    
    // will get call when user list recieve
    func didGetUserList(_ userlist: Array<Any>) {
        
        if let users = userlist as? [SignupUserData] {
            
            if isFirstTime {
                isFirstTime = false
                self.userArray = users
            } else {
                for user in users {
                    if user.type == .added {
                        self.userArray.append(user)
                    } else if user.type == .modified {
                        if self.userArray.contains(where: {$0.uid == user.uid})
                        {
                            let index = self.userArray.firstIndex(where: {$0.uid == user.uid})
                            self.userArray[index!] = user
                        }
                    } else if user.type == .removed {
                        self.userArray.removeAll(where: {$0.uid == user.uid})
                    }
                }
            }
            
            if isFirstTimeGroup {
                DispatchQueue.main.async {
                    self.userViewModel.userListVCDelegate?.getGroupList()
                }
            }
            
            self.tbl_userList.reloadData()
        }
    }
    
    func didGetGroupList(_ userlist: Array<Any>) {
        
        isFirstTimeGroup = false
        
        if let users = userlist as? [SignupUserData] {
        
            for user in users {
                
                print(user.fullName ,user.isGroup)
                
                guard let members = user.objGroupDetail?.members else { continue }
                
                if !members.contains(where: {$0 == currentUId}) {
                    self.userArray.removeAll(where: {$0.uid == user.uid})
                    continue
                }
                
                if user.type == .added {
                    self.userArray.append(user)
                } else if user.type == .modified {
                    if self.userArray.contains(where: {$0.uid == user.uid}) {
                        let index = self.userArray.firstIndex(where: {$0.uid == user.uid})
                        self.userArray[index!] = user
                    }
                } else if user.type == .removed {
                    self.userArray.removeAll(where: {$0.uid == user.uid})
                }
            }
            self.tbl_userList.reloadData()
        }
    }
}


// MARK: - Extended tableview delegate and datasource method
extension UserListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userListCell") as? UserListCell else { return UITableViewCell() }
        let item = self.userArray[indexPath.row]
        cell.lbl_userName.text = item.firstName + " " + item.lastName
        cell.img_user.setUserImageUsingUrl(item.profile_image , isUser: true)
        cell.imgOnlineOffLine.backgroundColor = item.isOnline ? .systemGreen : .lightGray
        cell.imgOnlineOffLine.borderWidth = 1
        cell.imgOnlineOffLine.cornerRadius = 5
        cell.imgOnlineOffLine.layer.borderColor = UIColor.white.cgColor
        cell.imgOnlineOffLine.isHidden = item.isGroup
        cell.accessoryType = .none
        if self.selectedForGroupCall.contains(where: {
            $0.uid == item.uid
        }) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.userArray[indexPath.row]
        if isMultipleSelection == true {
            
            if item.isGroup {
                Singleton.sharedSingleton.showToast(message: "You can select only users not group.")
                return
            }
            
            let cell = tbl_userList.cellForRow(at: indexPath)
            if self.selectedForGroupCall.contains(where: {
                $0.uid == item.uid
            }) {
                cell?.accessoryType = .none
                guard let index = self.selectedForGroupCall.firstIndex(where: {
                    $0.uid == item.uid
                }) else { return }
                self.selectedForGroupCall.remove(at: index)
            } else {
                cell?.accessoryType = .checkmark
                self.selectedForGroupCall.append(item)
            }
            self.tbl_userList.reloadData()
        } else {
            guard let vcc = Singleton.sharedSingleton.getController(storyName: Singleton.StoryboardName.Main, controllerName: Singleton.ControllerName.ChatVC) as? ChatVC else { return }
            vcc.userID = item.uid
            vcc.userName = item.firstName + " " + item.lastName
            vcc.objOppoUser = item
            Singleton.sharedSingleton.navigate(from: self, to: vcc, navigationController: self.navigationController)
        }
    }
}

