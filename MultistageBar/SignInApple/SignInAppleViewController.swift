//
//  SignInAppleViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit
import AuthenticationServices

@available(iOS 13.0, *)
class SignInAppleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(appleB)
    }
    
    @objc func appleSignAction() {
        let provider = ASAuthorizationAppleIDProvider.init()
        let request = provider.createRequest()
        request.requestedScopes = [ASAuthorization.Scope.email, ASAuthorization.Scope.fullName]
        
        let controller = ASAuthorizationController.init(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    lazy var appleB: ASAuthorizationAppleIDButton = {
        let temp = ASAuthorizationAppleIDButton.init(type: .signIn, style: .whiteOutline)
        temp.center = CGPoint.init(x: 100, y: 100)
        temp.addTarget(self, action: #selector(appleSignAction), for: .touchUpInside)
        return temp
    }()
}

@available(iOS 13.0, *)
extension SignInAppleViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let content = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("""
state: \(content.state),
userId: \(content.user),
authonizationCode: \(String.init(data: content.authorizationCode!, encoding: .utf8))
fullname:\(content.fullName)
email: \(content.email)
""")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("\(error)")
    }
}

@available(iOS 13.0, *)
extension SignInAppleViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

