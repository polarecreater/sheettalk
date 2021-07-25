
import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

//1. 로그인
//2. 채팅방 목록
//3. 채팅화면

private var messages: [Message] = []
private var messageListener: ListenerRegistration?
private let database = Firestore.firestore()
private var reference: CollectionReference?

final class ChatViewController: MessagesViewController {
  private let user: User
  private let channel: Channel

  init(user: User, channel: Channel) {
    self.user = user
    self.channel = channel
    super.init(nibName: nil, bundle: nil)

    title = channel.name
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    messageListener?.remove()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    listenToMessages()
    navigationItem.largeTitleDisplayMode = .never
    setUpMessageView()
    removeMessageAvatars()
  }
  private func listenToMessages() {
    guard let id = channel.id else {
      navigationController?.popViewController(animated: true)
      return
    }
     reference = database.collection("channels/\(id)/thread")
    messageListener = reference?
      .addSnapshotListener { [weak self] querySnapshot, error in
        guard let self = self else { return }
        guard let snapshot = querySnapshot else {
          print("""
            Error listening for channel updates: \
            \(error?.localizedDescription ?? "No error")
            """)
          return
        }

        snapshot.documentChanges.forEach { change in
          self.handleDocumentChange(change)
        }
      }
  }
  
  
 
  
  
  // MARK: - Helpers
  private func save(_ message: Message) {
    reference?.addDocument(data: message.representation) { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("Error sending message: \(error.localizedDescription)")
        return
      }
      self.messagesCollectionView.scrollToLastItem()
    }
  }
  
  
  private func insertNewMessage(_ message: Message) {
    if messages.contains(message) {
      return
    }

    messages.append(message)
    messages.sort()

    let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
    let shouldScrollToBottom =
      messagesCollectionView.isAtBottom && isLatestMessage

    messagesCollectionView.reloadData()

    if shouldScrollToBottom {
      messagesCollectionView.scrollToLastItem(animated: true)
    }
  }

  private func handleDocumentChange(_ change: DocumentChange) {
    guard let message = Message(document: change.document) else {
      return
    }

    switch change.type {
    case .added:
      insertNewMessage(message)
    default:
      break
    }
  }
  
  
  private func setUpMessageView() {
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .primary
    messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
    
    
  }
  
  private func removeMessageAvatars() {
    guard
      let layout = messagesCollectionView.collectionViewLayout
        as? MessagesCollectionViewFlowLayout
    else {
      return
    }
    layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
    layout.textMessageSizeCalculator.incomingAvatarSize = .zero
    layout.setMessageIncomingAvatarSize(.zero)
    layout.setMessageOutgoingAvatarSize(.zero)
    let incomingLabelAlignment = LabelAlignment(
      textAlignment: .left,
      textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
    layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
    let outgoingLabelAlignment = LabelAlignment(
      textAlignment: .right,
      textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
    layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
  }
}


// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
  // 1
  func footerViewSize(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGSize {
    return CGSize(width: 0, height: 8)
  }
  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 20
  }
 
 
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(
    _ inputBar: InputBarAccessoryView,
    didPressSendButtonWith text: String
  ) {
    // 1
    let message = Message(user: user, content: text)

    // 2
    save(message)

    // 3
    inputBar.inputTextView.text = ""
  }
}
// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
  // 1
  func numberOfSections(
    in messagesCollectionView: MessagesCollectionView
  ) -> Int {
    return messages.count
  }

  // 2
  func currentSender() -> SenderType {
    return Sender(senderId: user.uid, displayName: AppSettings.displayName)
  }

  // 3
  func messageForItem(
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> MessageType {
    return messages[indexPath.section]
  }

  // 4
  func messageTopLabelAttributedText(
    for message: MessageType,
    at indexPath: IndexPath
  ) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ])
  }
  
  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      if indexPath.section % 3 == 0 {
          return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
      }
      return nil
  }

}


// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
  // 1
  func backgroundColor(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> UIColor {
    return isFromCurrentSender(message: message) ? .primary : .incomingMessage
  }

  // 2
  func shouldDisplayHeader(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> Bool {
    return false
  }

  // 3
  func configureAvatarView(
    _ avatarView: AvatarView,
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) {
    avatarView.isHidden = true
  }

  // 4
  func messageStyle(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> MessageStyle {
    let corner: MessageStyle.TailCorner =
      isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
}
