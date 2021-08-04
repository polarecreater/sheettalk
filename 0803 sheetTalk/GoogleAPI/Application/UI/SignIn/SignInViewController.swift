//
//  SignInViewController.swift
//  GoogleAPI
//
//  Created by Dmitriy Petrov on 17/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import UIKit
//import FirebaseDatabase
import GoogleSignIn
class SignInViewController: UIViewController {
    @IBOutlet weak var googleSignInButton: UIButton!
    
    private let googleService = GoogleService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        googleSignInButton.layer.cornerRadius = 0.5 * googleSignInButton.bounds.size.height
        
        googleSignInButton.layer.masksToBounds = true
        googleSignInButton.layer.cornerRadius = 6.0
    }
    
    private func setupServices() {
        let driveFull = "https://www.googleapis.com/auth/drive"
        let sheetsFull = "https://www.googleapis.com/auth/spreadsheets"
        
        googleService.setPresentingViewController(self)
        googleService.setDelegate()
        googleService.setScopes(scopes: [driveFull, sheetsFull])
        googleService.restorePreviousSignIn()
    }

    
}

extension SignInViewController {
    @IBAction func signInButtonTapped(_ sender: Any?) {
        googleService.signIn()
        
    }
}
