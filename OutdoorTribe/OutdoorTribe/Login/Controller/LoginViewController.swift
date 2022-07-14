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
    
    @IBAction func tapPrivacyPolicyBtn(_ sender: Any) {
        let controller = WebView()
        controller.url = "https://www.privacypolicies.com/live/87961b7a-bce1-4d58-b679-0517b6dec594"
        present(controller, animated: true)
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
        performAppleSignIn()
    }

    func performAppleSignIn() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes =  [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }

    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                    }
                return random
                }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
                }
            }
        }
      return result
    }
}

import CryptoKit
// Unhashed nonce.
fileprivate var currentNonce: String?

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")}
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return }
    
            let  credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce)
            let firbaseAuth = Auth.auth()
            firbaseAuth.signIn(with: credential) { authDataResult, error in
                if let user = authDataResult?.user {
                    print("You're now signed in as \(user.uid), email: \(user.email), \(user.providerID)")
                    guard let userEmail = user.email else { return }
                    let givenName = appleIDCredential.fullName?.givenName ?? ""
                    let familyName = appleIDCredential.fullName?.familyName ?? ""
                    var userName = ""
                    if givenName == "" && familyName == "" {
                        userName = "\(UUID())" // 需要測試! 搭配apple user delete
                    } else {
                        userName = givenName + familyName
                    }
                    print("=======\(userName)")
                    let account = Account(email: userEmail,
                                          userID: user.uid,
                                          providerID: user.providerID,
                                          name: userName,
                                          photo: "",
                                          totalScore: 0,
                                          ratingCount: 0,
                                          point: 3500,
                                          followerCount: 0)
                    AccountManager.shared.storeRegistedAccount(account: account) { [weak self] result in
                        switch result {
                        case let .success(string):
                            print(string)
                            self?.dismiss(animated: true, completion: nil)
                        case let .failure(error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
