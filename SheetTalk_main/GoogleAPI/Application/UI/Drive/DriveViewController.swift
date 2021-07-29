//
//  DriveViewController.swift
//  GoogleAPI
//
//  Created by Dmitriy Petrov on 18/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import UIKit

class DriveViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = DriveViewModel()
    private let googleService = GoogleService()
    
    private var router = Router<DriveRouterPath>()

    var navigationTitle = "My Sheets"   // Sheet Title
    let userImage = UIImageView(image: UIImage(named: "user_img"))  // 사용자 사진
    
    var istableView = true
    var islatestOrder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = #colorLiteral(red: 0.9715676904, green: 0.9767020345, blue: 0.9721227288, alpha: 1)
        view.addSubview(toolBar)
        setupUI()
        
        setupTableView()
        collectionView.isHidden = true
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    private func setupTableView() {
        istableView = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 65
        tableView.register(UINib(nibName: "DriveTableViewCell", bundle: nil), forCellReuseIdentifier: "DriveTableViewCell")
        
        //tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        //tableView.topAnchor.constraint(equalTo: (self.navigationController?.navigationBar.bottomAnchor)!).isActive = true
        
        viewModel.getFiles(withToken: GoogleService.accessToken) { files in
            let files = files
            self.viewModel.driveFiles = files
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "DriveCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DriveCollectionViewCell")
        
        viewModel.getFiles(withToken: GoogleService.accessToken) { files in
            let files = files
            self.viewModel.driveFiles = files
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    
    
    private func getFiles() {
        viewModel.getFiles(withToken: GoogleService.accessToken) { files in
            let files = files
            self.viewModel.driveFiles = files
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // code 추가
    func setupUI() {    // UI 기본 설정 //NavigationBar -> Size, UserImg, SearchBar
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = navigationTitle
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.9715676904, green: 0.9767020345, blue: 0.9721227288, alpha: 1)
        self.navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.hidesSearchBarWhenScrolling = false        
        
        
        // 네비게이션바에 user image 추가
        navigationBar.addSubview(userImage)
        userImage.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        userImage.clipsToBounds = true
        userImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImage.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            userImage.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            userImage.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            userImage.widthAnchor.constraint(equalTo: userImage.heightAnchor),
            ])
    }
    
    @IBOutlet weak var changeSheetBtn: UIBarButtonItem!
    @IBAction func changeSheetView(_ sender: Any) {
        if istableView {
            if #available(iOS 13.0, *) {
                changeSheetBtn.image = UIImage(systemName: "list.bullet")
            } else {
                // Fallback on earlier versions
            }
            tableView.isHidden = true
            collectionView.isHidden = false
            istableView = false
            
        } else if !istableView {
            if #available(iOS 13.0, *) {
                changeSheetBtn.image = UIImage(systemName: "square.grid.2x2")
            } else {
                // Fallback on earlier versions
            }
            tableView.isHidden = false
            collectionView.isHidden = true
            istableView = true
        }
    }
    @IBOutlet weak var orderChangeBtn: UIBarButtonItem!
    @IBAction func changeSheetOrder(_ sender: Any) {
        // if문으로 상태 체크해서 상태에 따라 moveRowAt에서 함수 호출해야하는건가
        islatestOrder.toggle()
        
        if islatestOrder {
            viewModel.driveFiles.sort{ $0.name < $1.name }
            orderChangeBtn.title = "가나다순"
        }
        else {
            viewModel.driveFiles.sort{ $0.modifiedTime > $1.modifiedTime }
            orderChangeBtn.title = "최신순"
        }
        
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
}

extension DriveViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.driveFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DriveTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DriveTableViewCell else {
            fatalError()
        }
        
        let file = viewModel.driveFiles[indexPath.row]

        let datelabel = file.modifiedTime.components(separatedBy: "T")
        
        cell.sheetName.text = file.name
        cell.datelabel.text = datelabel[0]

        return cell
    }
}

extension DriveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = viewModel.driveFiles[indexPath.row]
        router.route(to: .spreadsheet(fromFile: file), from: self, type: .push)
    }
}

extension DriveViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.driveFiles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "DriveCollectionViewCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? DriveCollectionViewCell else {
            fatalError()
        }
        let file = viewModel.driveFiles[indexPath.row]
        
        cell.sheetName.text = file.name
        
        
        // file.thumbnailLink를 url자리에 넣어야함
        let imgUrl = URL(string: file.thumbnailLink)
//        var image: UIImage?

        
        var request = URLRequest(url: imgUrl!)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
//                    print("Download image fail : \(imgUrl!)")
                    return
            }

            DispatchQueue.main.async() {[weak self] in
//                print("Download image success \(imgUrl!)")

                cell.sheetImg.image = image
            }
        }.resume()
        
        
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: imgUrl!)
//            DispatchQueue.main.async {
//                image = UIImage(data: data!)
////                if (data != nil) {
////                    image = UIImage(data: data!)
////                } else if #available(iOS 13.0, *) {
////                        image = UIImage(systemName: "doc.text")!
////                } else {
////                        // Fallback on earlier versions
////                }
//
//            }
//        }
        //cell.sheetImg.image = UIImage(named: "thumbnail")
//        cell.sheetImg.image = image
        
//        print(cell.sheetName.text, "의 imgUrl: ", imgUrl)
        return cell
    }

}

extension DriveViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let file = viewModel.driveFiles[indexPath.row]
        router.route(to: .spreadsheet(fromFile: file), from: self, type: .push)
    }
}

extension DriveViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = 150
        let width = (Int(self.view.frame.size.width) - 54) / 2
//        let width = 180
        // 비율로 주고싶은데 어떻게 주는지 모르겠다
        return CGSize(width: width, height: height)
    }
    // cell 좌우 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    // cell 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}


private struct Const {
    static let ImageSizeForLargeState: CGFloat = 38
    static let ImageRightMargin: CGFloat = 20
    static let ImageBottomMarginForLargeState: CGFloat = 62
    static let NavBarHeightLargeState: CGFloat = 96.5
}
