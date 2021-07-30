
import UIKit

final class NavigationController: UINavigationController {
  override var shouldAutorotate: Bool {
    return false
  }
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .default
  }

  init(_ rootVC: UIViewController) {
    super.init(nibName: nil, bundle: nil)
    pushViewController(rootVC, animated: false)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationBar.tintColor = .black
    navigationBar.prefersLargeTitles = true
    navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    navigationBar.largeTitleTextAttributes = navigationBar.titleTextAttributes

    toolbar.tintColor = UIColor.black
  }
}
