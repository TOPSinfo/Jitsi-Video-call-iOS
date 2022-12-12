//
//  CreateGroupVC.swift
//  Firebase Chat iOS
//
//  Created by Tops on 22/10/21.
//

import UIKit
import FirebaseStorage
import Firebase
import TLPhotoPicker
import CropViewController

protocol CreateGroupVCDelegate: AnyObject {
    func uploadImage(fileData:Data?, fileName:String, type:MediaType)
    func createGroup(groupID:String, dic:[String:Any])
}

class CreateGroupVC: UIViewController {

    var userArray = [SignupUserData]()
    var selectedAssets = [TLPHAsset]()
    var selectedForGroupCall = [SignupUserData]()
    let createGroupViewmodel : CreateGroupViewModel = CreateGroupViewModel()
    var groupID = ""
    //MARK:- Outlet
    @IBOutlet weak var btn_back:UIButton!
    @IBOutlet weak var tf_groupName:UITextField!
    @IBOutlet weak var img_groupImage:UIImageView!
    @IBOutlet weak var collectionUsers: UICollectionView!
    @IBOutlet weak var lblParticipant: UILabel!
    
    var objGroup : GroupDetailObject = GroupDetailObject()
    var isForDetail : Bool = false
    
    @IBOutlet weak var btnCreateGroup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isForDetail {
            lblParticipant.text = String(format: "Participants : %d", self.objGroup.members.count)
            tf_groupName.text = objGroup.name
            tf_groupName.isUserInteractionEnabled = false
            img_groupImage.isUserInteractionEnabled = false
            img_groupImage.setUserImageUsingUrl(objGroup.groupIcon , isUser: true)
            btnCreateGroup.isHidden = true
        } else {
            lblParticipant.text = String(format: "Participants : %d", self.selectedForGroupCall.count)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // will set delegate firebase Auth view model
        self.createGroupViewmodel.firebaseCreateGroupViewModelDelegate = self
    }
        
    @IBAction func btn_backButtonTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Register button tapped
    @IBAction func btn_CreateGroupTapped(_ sender:UIButton) {

        if tf_groupName.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.groupname)
        } else if selectedAssets.count == 0 {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.groupImage)
        } else {
        
            var filename = String()
            for i in selectedAssets {
                filename = i.extType().rawValue
            }
            if let img = img_groupImage.image {
                let imgData = img.jpegData(compressionQuality: 1.0)
                createGroupViewmodel.createGroupVCDelegate?.uploadImage(fileData: imgData, fileName: ChildPath.userProfileImage + filename, type: .image)
            }
        }
    }
    
    @IBAction func btn_imageTapped(_ sender:UIButton){
        self.view.endEditing(true)
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = 1
        configure.singleSelectedMode = true
        configure.allowedVideoRecording = false
        configure.allowedVideo = false
        configure.allowedLivePhotos = false
        viewController.configure = configure
        self.present(viewController, animated: true, completion: nil)
    }
}
extension CreateGroupVC : TLPhotosPickerViewControllerDelegate , CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.img_groupImage.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    //TLPhotosPickerViewControllerDelegate
    func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        return true
    }
    
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker viewcontroller dismiss completion
        for i in selectedAssets {
                        
            let cropViewController = CropViewController(croppingStyle: .circular, image: i.fullResolutionImage ?? UIImage())
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
                        
        }
    }
        
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }
}


//MARK:- Extended tableview delegate and datasource method
extension CreateGroupVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isForDetail {
            return self.objGroup.members.count
        }
        return self.selectedForGroupCall.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! userListCollectionCell
        if isForDetail {
            FirebaseCloudFirestoreManager().getUserDetail(userID: self.objGroup.members[indexPath.row]) { objUser in
                cell.lbl_userName.text = objUser.fullName
                cell.img_user.setUserImageUsingUrl(objUser.profile_image , isUser: true)
            } failure: { error in
                
            }
        } else {
            let item = self.selectedForGroupCall[indexPath.row]
            cell.lbl_userName.text = item.fullName
            cell.img_user.setUserImageUsingUrl(item.profile_image , isUser: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 5 , height: 115)
    }
}

extension CreateGroupVC : FirebaseCreateGroupViewModelDelegate {
    
    func didUploadUserImage(task: StorageUploadTask?, reference: StorageReference?) {
        
        Singleton.sharedSingleton.showLoder()
        if let task = task {
            
            task.observe(.success) { snap in
                
                reference?.downloadURL(completion: { [self] url, error in
                    Singleton.sharedSingleton.hideLoader()
                    
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        print("download fail")
                        return
                    }
                    
                    let db: Firestore = Firestore.firestore()
                    self.groupID = db.collection("GroupDetail").document().documentID
                    
                    var dic = [String:Any]()
                    dic["id"] = self.groupID
                    dic["adminId"] = Singleton.appDelegate.objCurrentUser.uid
                    dic["adminName"] = Singleton.appDelegate.objCurrentUser.fullName
                    dic["createdAt"] = Timestamp.init(date: Date())
                    dic["groupIcon"] = downloadURL.description
                    var member = self.selectedForGroupCall.map({$0.uid})
                    member.append(Singleton.appDelegate.objCurrentUser.uid)
                    dic["members"] = member
                    dic["name"] = self.tf_groupName.text ?? ""
                    
                    self.createGroupViewmodel.createGroupVCDelegate?.createGroup(groupID: self.groupID, dic: dic)
                })
            }
            
            task.observe(.failure) { snap in
                Singleton.sharedSingleton.showToast(message: "Registration fail")
                Singleton.sharedSingleton.hideLoader()
            }
            
        } else {
            Singleton.sharedSingleton.showToast(message:"Registration fail")
            Singleton.sharedSingleton.hideLoader()
        }
    }
    
    func groupCreated(_ isRegister: Bool) {
        if isRegister {
            self.navigationController?.popViewController(animated: true)
        }
    }
}


class userListCollectionCell : UICollectionViewCell {
    @IBOutlet weak var img_user:UIImageView!
    @IBOutlet weak var lbl_userName:UILabel!
}

