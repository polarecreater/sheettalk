//
//  MoreViewController.swift
//  GoogleAPI
//
//  Created by 황윤경 on 2021/08/01.
//  Copyright © 2021 BytePace. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class MoreViewController: UIViewController {
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImg: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userID: UILabel!
    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var withdrawalBtn: UIButton!
    @IBOutlet weak var personalInfoBtn: UIButton!
    @IBOutlet weak var serviceBtn: UIButton!
    
    private let googleService = GoogleService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
//        userView.layer.cornerRadius = 10
        
        userImg.setImage(UIImage(named: "default_profile"), for: .normal)
        userName.text = AppSettings.displayName
        userID.text = GoogleService.userEmail
        

        logoutBtn.layer.borderWidth = 0.8
        logoutBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
//        logoutBtn.layer.cornerRadius = 10
        withdrawalBtn.layer.borderWidth = 0.8
        withdrawalBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
//        withdrawalBtn.layer.cornerRadius = 10
        personalInfoBtn.layer.borderWidth = 0.8
        personalInfoBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
//        personalInfoBtn.layer.cornerRadius = 10
        serviceBtn.layer.borderWidth = 0.8
        serviceBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
//        serviceBtn.layer.cornerRadius = 10
        
    }
    @IBAction func logOut(_ sender: Any) {
        let alertController = UIAlertController(
        title: nil,
        message: "정말 로그아웃 하시겠습니까?",
        preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(cancelAction)
        
        let signOutAction = UIAlertAction(
        title: "로그아웃",
        style: .destructive) { _ in
        do {
            try self.googleService.signOut()
        } catch {
        print("Error signing out: \(error.localizedDescription)")
        }
        }
        alertController.addAction(signOutAction)
        
        present(alertController, animated: true)
    }
    @IBAction func withdrawal(_ sender: Any) {
        let alertController = UIAlertController(
        title: nil,
        message: "모든 기록이 삭제되며 복구할 수 없습니다. 정말 탈퇴하시겠습니까?",
        preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(cancelAction)
        
        let signOutAction = UIAlertAction(
        title: "탈퇴하기",
        style: .destructive) { _ in
        do {
            try Auth.auth().signOut()
            self.googleService.signOut()
        } catch {
        print("Error signing out: \(error.localizedDescription)")
        }
        }
        alertController.addAction(signOutAction)
        
        present(alertController, animated: true)
    }
}
