//채팅코드 합치기

import UIKit
import Firebase

final class AppController {
  static let shared = AppController()
  // swiftlint:disable:next implicitly_unwrapped_optional
    
  private var window: UIWindow!
  private var rootViewController: UIViewController? {
    didSet {
      window.rootViewController = rootViewController
    }
  }

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAppState),
      name: .AuthStateDidChange,
      object: nil)
      FirebaseApp.configure()
  }

  // MARK: - Helpers
  func configureFirebase() {
    FirebaseApp.configure()
  }

  func show(in window: UIWindow?) {
    guard let window = window else {
      fatalError("Cannot layout app with a nil window.")
    }

    self.window = window
    window.tintColor = .orange
    window.backgroundColor = .white

    /*기존에 채팅 화면이 시작되는 방식
    handleAppState()

    window.makeKeyAndVisible()
 */
  }

  // MARK: - Notifications
  @objc private func handleAppState() {/*
    if let user = Auth.auth().currentUser {
      let channelsViewController = ChannelsViewController(currentUser: user)
      //루트 뷰 설정
      //rootViewController = NavigationController(channelsViewController)
    } else {
      //rootViewController = LoginViewController()
    }*/
  }
}

