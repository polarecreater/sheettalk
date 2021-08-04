//
//  AppDelegate.swift
//  GoogleAPI
//
//  Created by Dmitriy Petrov on 17/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    /*override init() {

            FirebaseApp.configure()

        }
*/
    var window: UIWindow?
    var tabBar: UITabBarController?
    
    private let id = "613169906838-ikn94o231ttkgrth8dkjvpo76vetq0en.apps.googleusercontent.com"
    private let testID = "224113705927-5jvh1cpjoe3gbvadpnlbhoffchdimd3t.apps.googleusercontent.com"
    private let googleService = GoogleService()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        //AppController.shared.configureFirebase()
        //FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings =  db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        googleService.setClientID(withID: id)
        
        setWindow()
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return googleService.handle(url: url)
    }
    
    //스크린 켜지는 부분 코드
    private func setWindow() {
        window = UIWindow()
        window?.rootViewController = getRootViewController()
        //window?.addSubview(tabBar!.view)
        window?.makeKeyAndVisible()
        
    }
    
    //로그인 스크린으로 시작
    private func getRootViewController() -> UIViewController {
        return SignInViewController.initFromNib()
    }
}
