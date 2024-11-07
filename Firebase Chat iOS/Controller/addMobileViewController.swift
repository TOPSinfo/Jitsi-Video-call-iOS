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
//import Firebase
import FirebaseFirestore

// MARK: - Controller custom protocol
protocol AddMobileViewControllerDelegate: AnyObject {
    func buttonClicked(phone: String) // call when user clicked
}

class AddMobileViewController: UIViewController {

    // MARK: Confirm Mobile Number outlets
    @IBOutlet weak var txtMobileNumber: MyGBTextField!
    @IBOutlet weak var cpv: CountryPickerView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblMobileChekmark: UILabel!

    // MARK: Member Variable
    var userInfo = SignupUserData()
    var phoneNumberUserEntered: String = ""
    var phoneNumber: PhoneNumber!
    var phonenumberKit = PhoneNumberUtility()

    // MARK: Viewmodel instancce
    private let loginViewModel: LoginViewModel = LoginViewModel()

    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration!.title = "Continue"
        txtMobileNumber.addTarget(self, action: #selector(mobileNumberTextDidChange(_:)), for: .editingChanged)
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        loginViewModel.firebaseAuthViewModelDelegate = self
    }

    // MARK: Textfield Delegate
    @objc func mobileNumberTextDidChange(_ textField: UITextField) {
        checkValidNumberAndUpdateUI()
    }

    // MARK: -  Setup UI 
    func setupUI() {

        cpv.delegate = self
        cpv.textColor = Singleton.AppColors.grayColor
        txtMobileNumber.isPartialFormatterEnabled = true
        self.txtMobileNumber.defaultRegion = cpv.selectedCountry.code
        txtMobileNumber.autocorrectionType = .no
        txtMobileNumber.textContentType = .telephoneNumber
        let number = phonenumberKit.getFormattedExampleNumber(forCountry: cpv.selectedCountry.code,
                                                              ofType: .mobile,
                                                              withFormat: .international, withPrefix: false)
        txtMobileNumber.placeholder = "\(number ?? "")"

    }

    // MARK: - Button Action
    // this will call when user press countinue button
    @IBAction func btnContinuePressed(_ sender: UIButton) {
        validateAndProcced()
    }

    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.txtMobileNumber.delegate = nil
        self.txtMobileNumber.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }

    func validateAndProcced() {
        // MARK: - Phone number validation and check
        var phoneNumberWithoutCountryCode = txtMobileNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard phoneNumberWithoutCountryCode != "" else {
            return
        }

        var phoneWithoutCode = phoneNumberWithoutCountryCode
        phoneWithoutCode = phoneWithoutCode!.replacingOccurrences(of: "(", with: "")
        phoneWithoutCode = phoneWithoutCode!.replacingOccurrences(of: ")", with: "")
        phoneWithoutCode = phoneWithoutCode!.replacingOccurrences(of: "-", with: "")
        phoneWithoutCode = phoneWithoutCode!.replacingOccurrences(of: " ", with: "")

        if phoneWithoutCode?.first == "0" {
            phoneWithoutCode?.removeFirst()
            phoneNumberWithoutCountryCode = phoneWithoutCode
        }

        guard phoneNumberWithoutCountryCode != "" else {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.enterMobileNumber)
            return
        }
        do {
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
        } catch {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.enterValidMobileNumber)
            return
        }

        var phoneNumber: String = "\(cpv.selectedCountry.phoneCode)\(phoneNumberWithoutCountryCode ?? "")"
        phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")

        phoneNumberUserEntered = phoneNumber
        self.userInfo.phone = phoneNumber

        // MARK: - call delegate to vefify number
        self.loginViewModel.addMobileViewControllerDelegate?.buttonClicked(phone: self.phoneNumberUserEntered)
    }

}

// MARK: - extension of controller of country picker
extension AddMobileViewController: CountryPickerViewDelegate {

    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        txtMobileNumber.isPartialFormatterEnabled = true
        self.txtMobileNumber.defaultRegion = country.code
        txtMobileNumber.autocorrectionType = .no
        txtMobileNumber.textContentType = .telephoneNumber
        let number = phonenumberKit.getFormattedExampleNumber(forCountry: country.code,
                                                              ofType: .mobile, withFormat: .international, withPrefix: false)
        txtMobileNumber.placeholder = "\(number ?? "")"
        checkValidNumberAndUpdateUI()
    }

    func checkValidNumberAndUpdateUI() {
        do {
            let phoneNumber = try phonenumberKit.parse(cpv.selectedCountry.phoneCode + txtMobileNumber.text!)
            _ = phonenumberKit.format(phoneNumber, toType: .international, withPrefix: false)
            lblMobileChekmark.textColor = UIColor(named: "ic_app_bar_color")
        } catch {
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

extension AddMobileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateAndProcced()
    }
}

// MARK: - Extension to extend Firebase Auth model view delegate
extension AddMobileViewController: FirebaseAuthViewModelDelegate {

    // MARK: - Will call from view model will navigate to OTP screen
    func sendOTP() {
        let singletone = Singleton.sharedSingleton
        guard let vcOTP = singletone.getController(storyName: Singleton.StoryboardName.Main,
        controllerName: Singleton.ControllerName.OTPViewController) as? OTPViewController else { return }
        vcOTP.userInfo = self.userInfo
        Singleton.sharedSingleton.navigate(from: self, toWhere: vcOTP, navigationController: self.navigationController)
    }
    // MARK: Will show error.
    func error(error: String, sign: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
}
