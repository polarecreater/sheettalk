import UIKit
import FirebaseAuth
import FirebaseDatabase
final class LoginViewController: UIViewController {
  @IBOutlet private var actionButton: UIButton!
  @IBOutlet private var fieldBackingView: UIView!
  @IBOutlet private var displayNameField: UITextField!
  @IBOutlet private var actionButtonBackingView: UIView!
  @IBOutlet private var bottomConstraint: NSLayoutConstraint!

    
    var ref: DatabaseReference!//post
        var refHandle : DatabaseHandle!
        var  ref2 : DatabaseReference!
        
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .orange
    fieldBackingView.smoothRoundCorners(to: 8)
    actionButtonBackingView.smoothRoundCorners(to: actionButtonBackingView.bounds.height / 2)

    displayNameField.tintColor = .orange
    displayNameField.addTarget(
      self,
      action: #selector(textFieldDidReturn),
      for: .primaryActionTriggered)

    registerForKeyboardNotifications()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    displayNameField.becomeFirstResponder()
  }

  // MARK: - Actions
  @IBAction private func actionButtonPressed() {
    signIn()
  }

  @objc private func textFieldDidReturn() {
    signIn()
  }

  // MARK: - Helpers
  private func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  private func signIn() {
    guard
      let name = displayNameField.text,
      !name.isEmpty
    else {
      showMissingNameAlert()
      return
    }

    displayNameField.resignFirstResponder()

    AppSettings.displayName = name
    Auth.auth().signInAnonymously()
    print("1")
    //기존에 채팅 화면이 시작되는 방식
    //handleAppState()
    
    //루트 컨트롤러 바꿔줌
    if #available(iOS 13.0, *) {
        let vc = MainTabBarController()
        
        print("3")
        DispatchQueue.main.async{
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
    print("2")
    
    //username입력
    ref = Database.database().reference()
    let object : [String:String] = [
        "username" : AppSettings.displayName
    ]
    ref.child("users/\(Int.random(in: 0..<100))").setValue(object)
  }

  private func showMissingNameAlert() {
    let alertController = UIAlertController(
      title: "Display Name Required",
      message: "Please enter a display name.",
      preferredStyle: .alert)

    let action = UIAlertAction(
      title: "Okay",
      style: .default) { _ in
      self.displayNameField.becomeFirstResponder()
    }
    alertController.addAction(action)
    present(alertController, animated: true)
  }

  // MARK: - Notifications
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
      let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber),
      let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)
    else {
      return
    }

    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve.uintValue << 16)
    bottomConstraint.constant = keyboardHeight + 20

    UIView.animate(
      withDuration: keyboardAnimationDuration.doubleValue,
      delay: 0,
      options: options) {
      self.view.layoutIfNeeded()
    }
  }

  @objc private func keyboardWillHide(_ notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber),
      let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)
    else {
      return
    }

    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve.uintValue << 16)
    bottomConstraint.constant = 20

    UIView.animate(
      withDuration: keyboardAnimationDuration.doubleValue,
      delay: 0,
      options: options) {
      self.view.layoutIfNeeded()
    }
  }
    /*
  @objc private func handleAppState() {
    if let user = Auth.auth().currentUser {
      let channelsViewController = ChannelsViewController(currentUser: user)
      //이건 안되네..?
      //channelsViewController.modalPresentationStyle = .fullScreen
      self.present(channelsViewController, animated: true, completion: nil)
      
      //rootViewController = NavigationController(channelsViewController)
    } else {
      //rootViewController = LoginViewController()
    }
    
    
  }*/
}
