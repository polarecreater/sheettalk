import UIKit
import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
  let id: String?
  var messageId: String {
    return id ?? UUID().uuidString
  }
  let content: String
  let sentDate: Date
  let sender: SenderType
  var kind: MessageKind {
    if let image = image {
      let mediaItem = ImageMediaItem(image: image)
      return .photo(mediaItem)
    } else {
      return .text(content)
    }
  }

  var image: UIImage?
  var downloadURL: URL?

  init(user: User, content: String) {
    sender = Sender(senderId: user.uid, displayName: AppSettings.displayName)
    self.content = content
    sentDate = Date()
    id = nil
  }

  init(user: User, image: UIImage) {
    sender = Sender(senderId: user.uid, displayName: AppSettings.displayName)
    self.image = image
    content = ""
    sentDate = Date()
    id = nil
  }

  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    guard
      let sentDate = data["created"] as? Timestamp,
      let senderId = data["senderId"] as? String,
      let senderName = data["senderName"] as? String
    else {
      return nil
    }

    id = document.documentID

    self.sentDate = sentDate.dateValue()
    sender = Sender(senderId: senderId, displayName: senderName)

    if let content = data["content"] as? String {
      self.content = content
      downloadURL = nil
    } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
      downloadURL = url
      content = ""
    } else {
      return nil
    }
  }
}

// MARK: - DatabaseRepresentation
extension Message: DatabaseRepresentation {
  var representation: [String: Any] {
    var rep: [String: Any] = [
      "created": sentDate,
      "senderId": sender.senderId,
      "senderName": sender.displayName
    ]

    if let url = downloadURL {
      rep["url"] = url.absoluteString
    } else {
      rep["content"] = content
    }

    return rep
  }
}

// MARK: - Comparable
extension Message: Comparable {
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
  }

  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
}
