//
//  MainTabBarController.swift
//  GoogleAPI
//
//  Created by 권혜민 on 2021/07/28.
//  Copyright © 2021 BytePace. All rights reserved.
//

import UIKit
import FirebaseAuth

@available(iOS 13.0, *)
class MainTabBarController: UITabBarController {
    //익명 로그인이 비동기라서 옵저버를 추가함
    var handle: AuthStateDidChangeListenerHandle?
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            tabBar.tintColor = .orange
            setupVCs()
            handle = Auth.auth().addStateDidChangeListener { auth, user in
                self.setupVCs()
            }
            
        }
    
    func setupVCs() {
        if let user = Auth.auth().currentUser {
          let channelsvc = ChannelsViewController(currentUser: user)
          //self.present(channelsViewController, animated: true, completion: nil)
            
            viewControllers = [
                createNavController(for: DriveViewController(), title: NSLocalizedString("Home", comment: ""), image: UIImage(systemName: "homekit")!),
                createNavController(for: channelsvc, title: NSLocalizedString("Chat", comment: ""), image: UIImage(systemName: "message.fill")!),
                
                createNavController(for: Test2ViewController(), title: NSLocalizedString("More", comment: ""), image: UIImage(systemName: "homekit")!)
            ]
          
        } else {
            print("sdfghjk")
        }
        
    }
    
    func createNavController(for rootViewController: UIViewController,
                                         title: String,
                                         image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        //navController.tabBarController?.tabBar.isHidden = true
        
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.navigationBar.backgroundColor = .quaternarySystemFill
        
        navController.navigationController?.navigationItem.searchController = UISearchController(searchResultsController: nil)
        navController.navigationController?.navigationItem.hidesSearchBarWhenScrolling = false
        
        
        return navController
    }


    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        storyboard.instantiateViewController(withIdentifier: "tabBar")
    }*/
    /*
    private func setTabBar(){
        //tabBar = UITabBarController()
        //tabBar = MainTabBarController()
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar:UITabBarController = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        tabBar.selectedIndex = 3
    }*/
}
