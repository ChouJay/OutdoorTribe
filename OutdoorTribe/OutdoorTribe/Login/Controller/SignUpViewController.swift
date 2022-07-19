//
//  SignUpViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var travelSlogan: UILabel!
    @IBOutlet weak var discoverySlogan: UILabel!
    @IBOutlet weak var adventureSlogan: UILabel!
    @IBOutlet weak var andSlogan1: UILabel!
    @IBOutlet weak var andSlogan2: UILabel!
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func tapSignUpBtn(_ sender: Any) {
        if nameTextField.text == "" {
            let alertController = UIAlertController(title: "Error",
                                                    message: "Please typing your name!",
                                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutStuff()
        
        // prevent layout issue for iphone 8
        if UIScreen.main.bounds.height < 700 {
            travelSlogan.isHidden = true
            discoverySlogan.isHidden = true
            adventureSlogan.isHidden = true
            andSlogan1.isHidden = true
            andSlogan2.isHidden = true
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            nameTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -270).isActive = true
        }
    }
    
    func layoutStuff() {
        signInBtn.layer.cornerRadius = 10
        changeTextFirldPlaceholderColor(textField: emailTextField, placeholderString: "Email")
        changeTextFirldPlaceholderColor(textField: passwordTextField, placeholderString: "Password")
        changeTextFirldPlaceholderColor(textField: nameTextField, placeholderString: "Name")
    }
    
    func changeTextFirldPlaceholderColor(textField: UITextField, placeholderString: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderString,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
}
