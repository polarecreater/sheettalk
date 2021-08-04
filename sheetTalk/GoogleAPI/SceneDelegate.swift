//co

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else {
      return
    }
    //let window = UIWindow(windowScene: windowScene)
    //AppController.shared.show(in: window)
    /*//탭바 때문에 추가된 부분
    //탭바 컨트롤러 객체 생성
    let tabBarController = UITabBarController()
    
    //뷰 객체 생성
    let view1 = LoginViewController()
    let view2 = HomeChatVC()
    
    //탭바 컨트롤러가 뷰 객체 제어
    tabBarController.viewControllers = [view1, view2]
    
    //탭바 아이템 만들기
    let view1Item = UITabBarItem(title: "Home", image: UIImage(systemName: "homekit"), tag:0)
    let view2Item = UITabBarItem(title: "Chat", image: UIImage(systemName: "message.fill"), tag:0)
    
    //탭바 아이템 적용
    view1.tabBarItem = view1Item
    view2.tabBarItem = view2Item
    
    //루트 뷰 설정
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
    
    //이렇게 하면 네비게이션바를 어떻게 하는지 모르겠다*/
  }
}
