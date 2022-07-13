//
//  SignUpViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func tapSignUpBtn(_ sender: Any) {
        if nameTextField.text == "" {
            let alertController = UIAlertController(title: "Please type your name!",
                                                    message: nil,
                                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            guard let emailString = emailTextField.text,
                  let passwordString = passwordTextField.text,
                  let nameString = nameTextField.text else { return }
            LoginManager.shared.nativeSignUp(email: emailString,
                                             password: passwordString,
                                             name: nameString) { [weak self] result in
                switch result {
                case let .success(message):
                    print(message)
                    self?.dismiss(animated: true, completion: nil)
                case let .failure(error):
                    print(error)
                    let alertController = UIAlertController(title: "Error",
                                                            message: error.localizedDescription,
                                                            preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
