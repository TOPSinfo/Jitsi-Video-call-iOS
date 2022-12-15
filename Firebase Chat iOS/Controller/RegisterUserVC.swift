//
//  RegisterUserVC.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import UIKit
import Firebase
import TLPhotoPicker
import CropViewController

// MARK: - custom delegate methos
protocol RegisterUserVCDelegate: AnyObject {
    func uploadImage(fileData: Data?, fileName: String, type: MediaType)
    func buttonClicked(userID: String, dic: [String:Any])
}

class RegisterUserVC: UIViewController {
    
    // MARK: - variable
    let registerViewModel: RegisterViewModel = RegisterViewModel()
    var userID = String()
    
    // MARK: - Outlet
    @IBOutlet weak var tf_FirstNmae: UITextField!
    @IBOutlet weak var tf_LastName: UITextField!
    @IBOutlet weak var tf_Email: UITextField!
    @IBOutlet weak var img_user: UIImageView!
    
    var selectedAssets = [TLPHAsset]()
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // will set delegate firebase Auth view model
        self.registerViewModel.firebaseAuthViewModelDelegate = self
    }
    
    // MARK: - Register button tapped
    @IBAction func btn_registerTapped(_ sender: UIButton) {
        
        if tf_FirstNmae.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.enterFirstName)
        } else if tf_LastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.enterlastName)
        } else if tf_Email.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.enteremail)
        } else if !Singleton.sharedSingleton.isValidEmail(tf_Email.text!) {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.enterValidemail)
        } else if selectedAssets.count == 0 {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.profileImage)
        } else {
            
            var filename = String()
            for i in selectedAssets {
                filename = i.extType().rawValue
            }
            if let img = img_user.image {
                let imgData = img.jpegData(compressionQuality: 1.0)
                registerViewModel.registerVCDelegate?.uploadImage(fileData: imgData, fileName: ChildPath.userProfileImage + filename, type: .image)
            }
        }
    }
    
    @IBAction func btn_pickPhoto(_ sender:UIButton) {
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
    
    @IBAction func btn_back(_ sender:UIButton) {
        Singleton.sharedSingleton.doOnlineOffline(isOnline: false)
        registerViewModel.firebaseViewModel.logautUser { (_) in
            Singleton.sharedSingleton.setNavigation()
        } failure: { (error) in
            Singleton.sharedSingleton.showToast(message: error)
        }
    }
    
}

// MARK: - Extended firebase Auth view model
extension RegisterUserVC: FirebaseAuthViewModelDelegate {
    
    func didUploadUserImage(task: StorageUploadTask?, reference: StorageReference?) {
 
        Singleton.sharedSingleton.showLoder()
        if let task = task {
            
            task.observe(.success) { _ in
                
                reference?.downloadURL(completion: { url, _ in
                    Singleton.sharedSingleton.hideLoader()
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        print("download fail")
                        return
                    }
                    
                    let uid = Auth.auth().currentUser?.uid ?? ""
                    var dic = [String:Any]()
                    dic["email"] = self.tf_Email.text ?? ""
                    dic["first_name"] = self.tf_FirstNmae.text ?? ""
                    dic["last_name"] = self.tf_LastName.text ?? ""
                    dic["phone"] = Auth.auth().currentUser?.phoneNumber
                    dic["uid"] = uid
                    dic["profile_image"] = downloadURL.description
                    dic["isOnline"] = true
                    dic["createdAt"] = Timestamp.init(date: Date())
                    self.registerViewModel.registerVCDelegate?.buttonClicked(userID: Auth.auth().currentUser?.uid ?? "", dic: dic)
                })
            }
            
            task.observe(.failure) { _ in
                Singleton.sharedSingleton.showToast(message: "Registration fail")
                Singleton.sharedSingleton.hideLoader()
            }
            
        } else {
            Singleton.sharedSingleton.showToast(message:"Registration fail")
            Singleton.sharedSingleton.hideLoader()
        }
    }
    
    // MARK: Will show error.
    func error(error: String, sign876: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
    // register callback
    func register(_ isRegister: Bool) {
        if isRegister {
            guard let vcUL = Singleton.sharedSingleton.getController(storyName: Singleton.StoryboardName.Main, controllerName: Singleton.ControllerName.UserListVC) as? UserListVC else { return }
            Singleton.sharedSingleton.navigate(from: self, to: vcUL, navigationController: self.navigationController)
        }         
    }
}

extension RegisterUserVC: TLPhotosPickerViewControllerDelegate , CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.img_user.image = image
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
