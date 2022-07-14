//
//  SignUpViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/27.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func tapSignUpBtn(_ sender: Any) {
        if nameTextField.text == "" {

            
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
        layoutGradientView()
        layoutStuff()
    }
    
    func layoutGradientView() {
        let gradientLayer = CAGradientLayer()
        let initialColor = UIColor.white // our initial color
        let finalColor = initialColor.withAlphaComponent(0.0)
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [initialColor.cgColor, finalColor.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientView.layer.addSublayer(gradientLayer)
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

