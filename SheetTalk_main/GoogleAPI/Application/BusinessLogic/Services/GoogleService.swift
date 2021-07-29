//
//  GoogleService.swift
//  GoogleAPI
//
//  Created by Dmitriy Petrov on 17/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import GoogleSignIn
import FirebaseAuth
class GoogleService: NSObject {
    
    
    static var accessToken: String = ""
    
    func setAccessToken() {
        guard let accessToken = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken else {
            fatalError()
        }
        GoogleService.accessToken = accessToken
    }
    
    
    
    func signIn() {
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func signOut() {
        GoogleService.accessToken = ""
        GIDSignIn.sharedInstance().signOut()
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController = SignInViewController.initFromNib()
        }
    }
    
    func restorePreviousSignIn() {
        guard !GIDSignIn.sharedInstance().hasPreviousSignIn() else {
            GIDSignIn.sharedInstance().restorePreviousSignIn()
            return
        }
    }
    
    func setPresentingViewController(_ vc: UIViewController) {
        GIDSignIn.sharedInstance().presentingViewController = vc
    }
    
    func setDelegate() {
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func setScopes(scopes: [String]) {
        GIDSignIn.sharedInstance().scopes = scopes
    }
    

    
    func setClientID(withID id: String) {
        GIDSignIn.sharedInstance().clientID = id
    }
    
    func handle(url: URL) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

extension GoogleService: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("New or signed out user")
            } else {
                print(error.localizedDescription)
            }
            return
        }
        self.setAccessToken()
        
        
        
          if let user = Auth.auth().currentUser {
            let channelsViewController = ChannelsViewController(currentUser: user)
            DispatchQueue.main.async{
                UIApplication.shared.keyWindow?.rootViewController = MainTabBarController()
            }
          } else {
            DispatchQueue.main.async{
                UIApplication.shared.keyWindow?.rootViewController = LoginViewController()
            }
          }
        
        /*
        //드라이브 컨트롤러 보여줌
        let vc = DriveViewController.initFromNib()
        //루트 컨트롤러 바뀜
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?
                .rootViewController = UINavigationController(rootViewController: vc)
        }*/
    }
}
