//
//  LoginVC.swift
//  rewards
//
//  Created by Kushal Vaghani on 25/09/2022.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var actIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var btnLogin: UIButton!
    
    //MARK: - Custom Method
    func setupView() {
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
        self.txtEmail.autocorrectionType = .no
        self.txtEmail.keyboardType = .emailAddress
    }
    
    //MARK: - Action Method
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        //Hide KeyBoard
        self.view.endEditing(true)
        //Check if the text field is Empty for email and password
        if self.txtEmail.text!.isEmpty {
            self.showAlertWithOKAction(title: "Error", message: "Please enter email") { oktapped in
                self.txtEmail.becomeFirstResponder()
            }
        } else if self.txtPassword.text!.isEmpty {
            self.showAlertWithOKAction(title: "Error", message: "Please enter password") { oktapped in
                self.txtPassword.becomeFirstResponder()
            }
        } else {
            //Hide Login button and show loader
            self.btnLogin.isHidden = true
            self.actIndicatorView.isHidden = false
            //Api call for authantication in firebase
            Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let loginError = error {
                    strongSelf.btnLogin.isHidden = false
                    strongSelf.actIndicatorView.isHidden = true
                    strongSelf.showAlertWithOKAction(title: "Error", message: loginError.localizedDescription)
                } else if let result = authResult {
                    //Get Current User Login from Firebase SDK
                    guard let email = result.user.email else { return }
                    //Get Email from Current Login User
                    //Check email content for manager or employee
                    if email.contains("manager") { //if manager then... going to manager VC
                        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManagerDashboardNVC")
                        AppDelegate.shared.window?.rootViewController = VC
                        AppDelegate.shared.window?.makeKeyAndVisible()
                    } else { //else..... going to employee VC
                        let NVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmployeeDashboardNVC")
                        AppDelegate.shared.window?.rootViewController = NVC
                        AppDelegate.shared.window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }

    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
}

//MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
