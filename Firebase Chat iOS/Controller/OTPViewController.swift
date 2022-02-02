//
//  OTPViewController.swift
//  BDSClient
//
//  Created by iOS Developer on 13/04/20.
//  Copyright © 2020 Govind Rakholiya. All rights reserved.
//

import UIKit
import SVPinView
import AuthenticationServices
import Firebase
import FirebaseFirestore

//MARK:- Custom delegate
protocol OTPViewControllerDelegate: AnyObject {
    func verifyPhone(phone:String) //verify phone to send OTP
    func buttonClicked(verificationId:String,code:String) // Button click
    func checkUserAvailability(userID:String) // check user availability
}

class OTPViewController: UIViewController,UITextViewDelegate {
    
    //MARK:- view model object
    private let otpViewModel: OTPViewModel = OTPViewModel()
    
    //MARK:- Outelets
    @IBOutlet weak var btnSignInLater: UIButton!
    @IBOutlet weak var btnLoginWithEmailAddress: UIButton!
    @IBOutlet weak var btnResendCode: UIButton!
    @IBOutlet weak var btnSignInWithPassword: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var pinView: SVPinView!
    
    var forUpdateMobileNumber : Bool = false // This variable true means user want to update his mobile number
    
    //User Info From Previous controller
    var userInfo = SignupUserData()
    
    //Verification id
    var verificationId : String = ""
    var isExpire : Bool = false
    
    //For Timer Purpose
    var countdownTimer: Timer!
    var totalTime = 60
    
    //UserId From phone number authentication
    var userId : String = "AAAAAAAAAAAA"
    
    //MARK:- Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showKeyboard()
        setupUI()
        verifyPhoneNumber()
        
        //Pinview call back method to recieve entered pin
        pinView.didFinishCallback = { [weak self] pin in
            self!.pinEntered()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set delegate of view model of Auth
        otpViewModel.firebaseAuthViewModelDelegate = self
    }
    
    //MARK:- Will show kebard with selected filed
    func showKeyboard() {
        pinView.style = .underline
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            
            for viewT in self.pinView.subviews
            {
                for viewTT in viewT.subviews
                {
                    for (i,viewTTT) in viewTT.subviews.enumerated()
                    {
                        for viewTTTT in viewTTT.subviews
                        {
                            for viewTTTTT in viewTTTT.subviews
                            {
                                for viewTTTTTT in viewTTTTT.subviews
                                {
                                    if viewTTTTTT is UITextField
                                    {
                                        (viewTTTTTT as! UITextField).text = ""
                                        if i == 0 {
                                            if #available(iOS 12.0, *) {
                                                (viewTTTTTT as! UITextField).textContentType = .oneTimeCode
                                            }
                                            (viewTTTTTT as! UITextField).becomeFirstResponder()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    //MARK:-  Setup UI 
    func setupUI() {
        pinView.pinLength = 6
        pinView.borderLineColor = Singleton.appColors.grayColor
        pinView.activeBorderLineColor = Singleton.appColors.grayColor
    }
    
    //MARK: Countinue Button Action
    @IBAction func btnContinuePressed(_ sender: UIButton) {
        self.pinEntered()
    }
    
    //MARK:- Resend Code
    @IBAction func btnResendpressed(_ sender: UIButton) {
        if (totalTime == 0){
            pinView.clearPin()
            countdownTimer.invalidate()
            totalTime = 60
            verifyPhoneNumber()
        }
    }
    
    //MAKR:- will send otp on mobile entered in prevois screen
    func verifyPhoneNumber() {
        self.otpViewModel.OTPViewControllerDelegate?.verifyPhone(phone: userInfo.phone)
    }
    
    //MARK:-  TIMER 
    func startTimer() {
        self.lblTimer.isHidden = false
        btnResendCode.isEnabled = false
        btnResendCode.setTitleColor(Singleton.appColors.themeColoer.withAlphaComponent(0.3), for: .disabled)
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        lblTimer.text = "\(timeFormatted(totalTime))"
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    func endTimer() {
        self.lblTimer.isHidden = true
        btnResendCode.isEnabled =  true
        
        
        btnResendCode.setTitleColor(Singleton.appColors.themeColoer, for: .normal)
        
        isExpire = true
        countdownTimer.invalidate()
    }
    
    //MARK:-  Textview Delegate for Edit Number tap
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (forUpdateMobileNumber){
            self.navigationController?.popViewController(animated: true)
            return true
        } else {
            
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: addMobileViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        return false
    }
    
    
    //MARK:- OTP Validation method
    func pinEntered() {
        guard pinView.getPin().count == 6 else {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterProperPin)
            return
        }
        
        guard verificationId != "" else {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.somethingWentWrong)
            return
        }
        
        guard isExpire == false else {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.otpExpired)
            return
        }
        
        otpViewModel.OTPViewControllerDelegate?.buttonClicked(verificationId: self.verificationId, code: pinView.getPin())
        
    }
    
    @IBAction func btnBackPresed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- extended firebase Auth View Model
extension OTPViewController: FirebaseAuthViewModelDelegate {
    //MARK: Will show error.
    func error(error: String, sign: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
    
    // Will get verification id after sending OTP
    func verifyphone(_ verificationID: String) {
        self.verificationId = verificationID
        self.startTimer()
    }
    
    // Will get user id after login and call check user availability
    func login(_ authResult: AuthDataResult?) {
        
        if let userDetail = authResult {
            let id = userDetail.user.uid
            otpViewModel.OTPViewControllerDelegate?.checkUserAvailability(userID: id)
        }
    }
    
    // Will give result of user availbility and redirect conditionally to controller
    func checkAvalability(_ isRegisterd: Bool) {
        
        if isRegisterd {
            
            otpViewModel.firebaseViewModel.firebaseCloudFirestoreManager.getUserDetail(userID: Auth.auth().currentUser!.uid) { (userData) in
                
                let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.UserListVC) as! UserListVC
                Singleton.sharedSingleton.navigate(from: self, to: vc, navigationController: self.navigationController)
                
            } failure: { (error) in
                print(error)
            }
            
            
        } else {
            let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.RegisterUserVC) as! RegisterUserVC
            Singleton.sharedSingleton.navigate(from: self, to: vc, navigationController: self.navigationController)
        }
        
    }
    
}
