import UIKit
import FirebaseAuth
import FirebaseFirestore


final class ChannelsViewController: UITableViewController {
  
  var filteredChannels = [Channel]()
  
  let searchController = UISearchController(searchResultsController: nil)
  private let toolbarLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()

  private let channelCellIdentifier = "channelCell"
  private var currentChannelAlertController: UIAlertController?

  private let database = Firestore.firestore()
  private var channelReference: CollectionReference {
    return database.collection("channels")
  }

  private var channels: [Channel] = []
  private var channelListener: ListenerRegistration?
  private let currentUser: User

  deinit {
    channelListener?.remove()
  }

  init(currentUser: User) {
    self.currentUser = currentUser
    super.init(style: .grouped)

    title = "Chat"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search"
    navigationItem.searchController = searchController
    navigationItem.rightBarButtonItem = editButtonItem
    definesPresentationContext = true
    

    clearsSelectionOnViewWillAppear = true
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)

    toolbarItems = [
    //  UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(customView: toolbarLabel),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    ]
    //toolbarLabel.text = AppSettings.displayName

    channelListener = channelReference.addSnapshotListener { [weak self] querySnapshot, error in
      guard let self = self else { return }
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }

      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isToolbarHidden = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isToolbarHidden = true
  }
/*
  // MARK: - Actions
  @objc private func signOut() {
    let alertController = UIAlertController(
      title: nil,
      message: "Are you sure you want to sign out?",
      preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancelAction)

    let signOutAction = UIAlertAction(
      title: "Sign Out",
      style: .destructive) { _ in
      do {
        try Auth.auth().signOut()
      } catch {
        print("Error signing out: \(error.localizedDescription)")
      }
    }
    alertController.addAction(signOutAction)

    present(alertController, animated: true)
  }
*/
  @objc private func addButtonPressed() {
    let alertController = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alertController.addTextField { field in
      field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
      field.enablesReturnKeyAutomatically = true
      field.autocapitalizationType = .words
      field.clearButtonMode = .whileEditing
      field.placeholder = "Channel name"
      field.returnKeyType = .done
      field.tintColor = .orange
    }

    let createAction = UIAlertAction(
      title: "Create",
      style: .default) { _ in
      self.createChannel()
    }
    createAction.isEnabled = false
    alertController.addAction(createAction)
    alertController.preferredAction = createAction

    present(alertController, animated: true) {
      alertController.textFields?.first?.becomeFirstResponder()
    }
    currentChannelAlertController = alertController
  }

  @objc private func textFieldDidChange(_ field: UITextField) {
    guard let alertController = currentChannelAlertController else {
      return
    }
    alertController.preferredAction?.isEnabled = field.hasText
  }

  // MARK: - Helpers
  private func createChannel() {
    guard
      let alertController = currentChannelAlertController,
      let channelName = alertController.textFields?.first?.text
    else {
      return
    }

    let channel = Channel(name: channelName)
    channelReference.addDocument(data: channel.representation) { error in
      if let error = error {
        print("Error saving channel: \(error.localizedDescription)")
      }
    }
  }

  private func addChannelToTable(_ channel: Channel) {
    if channels.contains(channel) {
      return
    }

    channels.append(channel)
    channels.sort()

    guard let index = channels.firstIndex(of: channel) else {
      return
    }
    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }

  private func updateChannelInTable(_ channel: Channel) {
    guard let index = channels.firstIndex(of: channel) else {
      return
    }

    channels[index] = channel
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }

  private func removeChannelFromTable(_ channel: Channel) {
    guard let index = channels.firstIndex(of: channel) else {
      return
    }

    channels.remove(at: index)
    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }

  private func handleDocumentChange(_ change: DocumentChange) {
    guard let channel = Channel(document: change.document) else {
      return
    }

    switch change.type {
    case .added:
      addChannelToTable(channel)
    case .modified:
      updateChannelInTable(channel)
    case .removed:
      removeChannelFromTable(channel)
    }
  }
}

// MARK: - TableViewDelegate
extension ChannelsViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return filteredChannels.count
    }
      
    return channels.count
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
    let channel: Channel
    if isFiltering() {
      channel = filteredChannels[indexPath.row]
    } else {
      channel = channels[indexPath.row]
    }
    cell.textLabel!.text = channel.name
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let channel = channels[indexPath.row]
    let viewController = ChatViewController(user: currentUser, channel: channel)
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
            
              
              channels.remove(at: indexPath.row)
              tableView.deleteRows(at: [indexPath], with: .fade)
              
          } else if editingStyle == .insert {
              
          }
  }
}

//chat 검색 기능
extension ChannelsViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
  
  
  func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
    return searchController.searchBar.text?.isEmpty ?? true
  }
    
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filteredChannels = channels.filter({( channel : Channel) -> Bool in
      return channel.name.lowercased().contains(searchText.lowercased())
    })

    tableView.reloadData()
  }
  
  func isFiltering() -> Bool {
    return searchController.isActive && !searchBarIsEmpty()
  }
  
  
  
  
  
}
