//
//  CreateGroupVC.swift
//  Firebase Chat iOS
//
//  Created by Tops on 22/10/21.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import TLPhotoPicker
import CropViewController
import FirebaseFirestoreInternal
import FirebaseCore

protocol CreateGroupVCDelegate: AnyObject {
    func uploadImage(fileData: Data?, fileName: String, type: MediaType)
    func createGroup(groupID: String, dic: [String: Any])
}

class CreateGroupVC: UIViewController {

    var userArray = [SignupUserData]()
    var selectedAssets = [TLPHAsset]()
    var selectedForGroupCall = [SignupUserData]()
    let createGroupViewmodel: CreateGroupViewModel = CreateGroupViewModel()
    var groupID = ""

    // MARK: - Outlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tfGroupName: UITextField!
    @IBOutlet weak var imgGroupImage: UIImageView!
    @IBOutlet weak var collectionUsers: UICollectionView!
    @IBOutlet weak var lblParticipant: UILabel!

    var objGroup: GroupDetailObject = GroupDetailObject()
    var isForDetail: Bool = false

    @IBOutlet weak var btnCreateGroup: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isForDetail {
            lblParticipant.text = String(format: "Participants : %d", self.objGroup.members.count)
            tfGroupName.text = objGroup.name
            tfGroupName.isUserInteractionEnabled = false
            imgGroupImage.isUserInteractionEnabled = false
            imgGroupImage.setUserImageUsingUrl(objGroup.groupIcon, isUser: true)
            btnCreateGroup.isHidden = true
        } else {
            lblParticipant.text = String(format: "Participants : %d", self.selectedForGroupCall.count)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // will set delegate firebase Auth view model
        self.createGroupViewmodel.firebaseCreateGroupViewModelDelegate = self
    }

    @IBAction func btn_backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Register button tapped
    @IBAction func btn_CreateGroupTapped(_ sender: UIButton) {
        if tfGroupName.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.groupname)
        } else if selectedAssets.count == 0 {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.groupImage)
        } else {
            var filename = String()
            for ind in selectedAssets {
                filename = ind.extType().rawValue
            }
            if let img = imgGroupImage.image {
                let imgData = img.jpegData(compressionQuality: 1.0)
                createGroupViewmodel.createGroupVCDelegate?.uploadImage(fileData: imgData,
                fileName: ChildPath.userProfileImage + filename, type: .image)
            }
        }
    }

    @IBAction func btn_imageTapped(_ sender: UIButton) {
        openImagePicker(self)
    }
}

extension CreateGroupVC: TLPhotosPickerViewControllerDelegate, CropViewControllerDelegate {

    func cropViewController(_ cropViewController: CropViewController,
                            didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.imgGroupImage.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }

    // TLPhotosPickerViewControllerDelegate
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
        for ind in selectedAssets {
            let cropViewController = CropViewController(croppingStyle: .circular,
                                                        image: ind.fullResolutionImage ?? UIImage())
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

// MARK: - Extended tableview delegate and datasource method
extension CreateGroupVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isForDetail {
            return self.objGroup.members.count
        }
        return self.selectedForGroupCall.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                         for: indexPath) as? UserListCollectionCell else { return UICollectionViewCell() }
        if isForDetail {
            FirebaseCloudFirestoreManager().getUserDetail(userID: self.objGroup.members[indexPath.row]) { objUser in
                cell.lblUserName.text = objUser.fullName
                cell.imgUser.setUserImageUsingUrl(objUser.profileImage, isUser: true)
            } failure: { _ in

            }
        } else {
            let item = self.selectedForGroupCall[indexPath.row]
            cell.lblUserName.text = item.fullName
            cell.imgUser.setUserImageUsingUrl(item.profileImage, isUser: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 5, height: 115)
    }
}

extension CreateGroupVC: FirebaseCreateGroupViewModelDelegate {

    func didUploadUserImage(task: StorageUploadTask?, reference: StorageReference?) {

        Singleton.sharedSingleton.showLoder()
        if let task = task {

            task.observe(.success) { _ in

                reference?.downloadURL(completion: { [self] url, _ in
                    Singleton.sharedSingleton.hideLoader()
                    
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        print("download fail")
                        return
                    }

                    let dbs: Firestore = Firestore.firestore()
                    self.groupID = dbs.collection("GroupDetail").document().documentID

                    var dic = [String: Any]()
                    dic["id"] = self.groupID
                    dic["adminId"] = Singleton.appDelegate?.objCurrentUser.uid
                    dic["adminName"] = Singleton.appDelegate?.objCurrentUser.fullName
                    dic["createdAt"] = Timestamp.init(date: Date())
                    dic["groupIcon"] = downloadURL.description
                    var member = self.selectedForGroupCall.map({$0.uid})
                    member.append(Singleton.appDelegate?.objCurrentUser.uid ?? "")
                    dic["members"] = member
                    dic["name"] = self.tfGroupName.text ?? ""
                    
                    self.createGroupViewmodel.createGroupVCDelegate?.createGroup(groupID: self.groupID, dic: dic)
                })
            }

            task.observe(.failure) { _ in
                Singleton.sharedSingleton.showToast(message: "Registration fail")
                Singleton.sharedSingleton.hideLoader()
            }

        } else {
            Singleton.sharedSingleton.showToast(message: "Registration fail")
            Singleton.sharedSingleton.hideLoader()
        }
    }

    func groupCreated(_ isRegister: Bool) {
        if isRegister {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

class UserListCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
}
