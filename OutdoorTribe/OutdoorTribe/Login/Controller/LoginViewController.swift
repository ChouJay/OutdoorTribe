//
//  LoginViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import UIKit
import FirebaseAuth
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func tapDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapLoginBtn(_ sender: Any) {
        guard let emailString = emailTextField.text,
              let passwordString = passwordTextField.text else { return }
        LoginManager.shared.nativeSignIn(email: emailString, password: passwordString) { [weak self] result in
            switch result {
            case let .success(string):
                self?.dismiss(animated: true, completion: nil)
                print(string)
            case let .failure(error):
                print(error)
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutAppleSignInButton()
        // Do any additional setup after loading the view.
    }
    
    func layoutAppleSignInButton() {
        let appleSignInBtn = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black)
        view.addSubview(appleSignInBtn)
        appleSignInBtn.layer.cornerRadius = 15
        appleSignInBtn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        
        appleSignInBtn.translatesAutoresizingMaskIntoConstraints = false
        appleSignInBtn.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 85).isActive = true
        appleSignInBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        appleSignInBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        appleSignInBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func signInWithApple() {
        
    }
}
