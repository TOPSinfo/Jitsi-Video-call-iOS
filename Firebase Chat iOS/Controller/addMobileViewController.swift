//
//  addMobileViewController.swift
//  BDSClient
//
//  Created by iOS Developer on 10/04/20.
//  Copyright © 2020 Govind Rakholiya. All rights reserved.
//

import UIKit
import CountryPickerView
import PhoneNumberKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseFirestore

// MARK: - Controller custom protocol
protocol addMobileViewControllerDelegate: AnyObject {
    func buttonClicked(phone:String) // call when user clicked
}

class addMobileViewController: UIViewController {
    
    // MARK: Confirm Mobile Number outlets
    @IBOutlet weak var txtMobileNumber: MyGBTextField!
    @IBOutlet weak var cpv: CountryPickerView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblMobileChekmark: UILabel!
    
    // MARK: Member Variable
    var userInfo = SignupUserData()
    var phoneNumberUserEntered : String = ""
    var phoneNumber : PhoneNumber!
    var phonenumberKit = PhoneNumberKit()
    
    // MARK: Viewmodel instancce
    private let loginViewModel: LoginViewModel = LoginViewModel()
    
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Continue"
        txtMobileNumber.addTarget(self, action: #selector(mobileNumberTextDidChange(_:)), for: .editingChanged)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loginViewModel.firebaseAuthViewModelDelegate = self
    }
    
    // MARK: Textfield Delegate
    @objc func mobileNumberTextDidChange(_ textField: UITextField) {
        
        do{
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
            lblMobileChekmark.textColor = UIColor(named: "ic_app_bar_color")
        }catch{
            lblMobileChekmark.textColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)
            return
        }
        
    }
    
    // MARK: -  Setup UI 
    func setupUI() {
        
        cpv.delegate = self
        cpv.textColor = Singleton.appColors.grayColor
        txtMobileNumber.isPartialFormatterEnabled = true
        self.txtMobileNumber.defaultRegion = cpv.selectedCountry.code
        txtMobileNumber.autocorrectionType = .no
        txtMobileNumber.textContentType = .telephoneNumber
        let number = phonenumberKit.getFormattedExampleNumber(forCountry: cpv.selectedCountry.code, ofType: .mobile, withFormat: .international, withPrefix: false)
        txtMobileNumber.placeholder = "\(number ?? "")"
        
    }
    
    // MARK: - Button Action
    // this will call when user press countinue button
    @IBAction func btnContinuePressed(_ sender: UIButton) {
        
        // MARK: - Phone number validation and check
        var phoneNumberWithoutCountryCode = txtMobileNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard phoneNumberWithoutCountryCode != "" else {
            return
        }
        
        var PhoneWithoutCOde = phoneNumberWithoutCountryCode
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: "(", with: "")
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: ")", with: "")
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: "-", with: "")
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: " ", with: "")
        
        if (PhoneWithoutCOde?.first == "0"){
            PhoneWithoutCOde?.removeFirst()
            phoneNumberWithoutCountryCode = PhoneWithoutCOde
            
        }
        
        do{
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
        }catch{
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterValidMobileNumber)
            return
        }
        
        let numberAsInt : Int = Int(PhoneWithoutCOde ?? "")!
        PhoneWithoutCOde = "\(numberAsInt)"
        
        guard phoneNumberWithoutCountryCode != "" else {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterMobileNumber)
            return
        }
        do{
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
        }catch{
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterValidMobileNumber)
            return
        }
        
        var PhoneNumber : String = "\(cpv.selectedCountry.phoneCode)\(phoneNumberWithoutCountryCode ?? "")"
        PhoneNumber = PhoneNumber.replacingOccurrences(of: "(", with: "")
        PhoneNumber = PhoneNumber.replacingOccurrences(of: ")", with: "")
        PhoneNumber = PhoneNumber.replacingOccurrences(of: "-", with: "")
        PhoneNumber = PhoneNumber.replacingOccurrences(of: " ", with: "")
        
        
        phoneNumberUserEntered = PhoneNumber
        self.userInfo.phone = PhoneNumber
        
        // MARK: - call delegate to vefify number
        self.loginViewModel.addMobileViewControllerDelegate?.buttonClicked(phone: self.phoneNumberUserEntered)
        
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
        self.txtMobileNumber.delegate = nil
        self.txtMobileNumber.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - extension of controller of country picker
extension addMobileViewController : CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        txtMobileNumber.isPartialFormatterEnabled = true
        self.txtMobileNumber.defaultRegion = country.code
        txtMobileNumber.autocorrectionType = .no
        txtMobileNumber.textContentType = .telephoneNumber
        let number = phonenumberKit.getFormattedExampleNumber(forCountry: country.code, ofType: .mobile, withFormat: .international, withPrefix: false)
        txtMobileNumber.placeholder = "\(number ?? "")"
        
        do{
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
            lblMobileChekmark.textColor = UIColor(named: "ic_app_bar_color")
        }catch{
            lblMobileChekmark.textColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)
            return
        }
    }
}

// MARK: - Extending to class to change default country selection
class MyGBTextField: PhoneNumberTextField {
    override var defaultRegion: String {
        get {
            return "US"
        }
        set {
            
        } // exists for backward compatibility
    }
    
}

extension addMobileViewController : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // MARK: Phone number validation
        var phoneNumberWithoutCountryCode = txtMobileNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard phoneNumberWithoutCountryCode != "" else {
            return
        }
        
        var PhoneWithoutCOde = phoneNumberWithoutCountryCode
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: "(", with: "")
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: ")", with: "")
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: "-", with: "")
        PhoneWithoutCOde = PhoneWithoutCOde!.replacingOccurrences(of: " ", with: "")
        
        if (PhoneWithoutCOde?.first == "0"){
            PhoneWithoutCOde?.removeFirst()
            phoneNumberWithoutCountryCode = PhoneWithoutCOde
            
        }
        
        do{
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
        }catch{
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterValidMobileNumber)
            return
        }
        
        let numberAsInt : Int = Int(PhoneWithoutCOde ?? "")!
        PhoneWithoutCOde = "\(numberAsInt)"
        
        guard phoneNumberWithoutCountryCode != "" else {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterMobileNumber)
            return
        }
        do{
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
        }catch{
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterValidMobileNumber)
            return
        }
        
        var PhoneNumber = "\(cpv.selectedCountry.phoneCode)\(phoneNumberWithoutCountryCode ?? "")"
        PhoneNumber = PhoneNumber.replacingOccurrences(of: "(", with: "")
        PhoneNumber = PhoneNumber.replacingOccurrences(of: ")", with: "")
        PhoneNumber = PhoneNumber.replacingOccurrences(of: "-", with: "")
        PhoneNumber = PhoneNumber.replacingOccurrences(of: " ", with: "")
        
        phoneNumberUserEntered = PhoneNumber
        self.userInfo.phone = PhoneNumber
        
        // MARK: - call delegate to vefify number
        self.loginViewModel.addMobileViewControllerDelegate?.buttonClicked(phone: self.phoneNumberUserEntered)
        
    }
}

// MARK: - Extension to extend Firebase Auth model view delegate
extension addMobileViewController : FirebaseAuthViewModelDelegate{
    
    // MARK: - Will call from view model will navigate to OTP screen
    func sendOTP() {
        guard let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.OTPViewController) as? OTPViewController else { return }
        vc.userInfo = self.userInfo
        Singleton.sharedSingleton.navigate(from: self, to: vc, navigationController: self.navigationController)
    }
    // MARK: Will show error.
    func error(error: String, sign: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
    
}
