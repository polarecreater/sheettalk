//
//  SpreadsheetViewController.swift
//  GoogleAPI
//
//  Created by Dmitriy Petrov on 18/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import UIKit
import SpreadsheetView

class SpreadsheetViewController: UIViewController {
    let spreadsheetView = SpreadsheetView()
    var isSheetLoad = false
    var viewModel: SpreadsheetViewModel!
    @IBOutlet weak var toolBar: UIToolbar!    
    @IBOutlet weak var chatBar: UIView!
    
    @IBOutlet weak var x: UITextField!
    @IBOutlet weak var y: UITextField!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var inputBtn: UIButton!
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        spreadsheetView.register(SpreadsheetViewCell.self, forCellWithReuseIdentifier: SpreadsheetViewCell.identifier)
        spreadsheetView.dataSource = self
        
        //let navController = UINavigationController(rootViewController: rootViewController)
        //navController.tabBarController?.tabBar.isHidden = true
        navigationController?.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false

        // navigationBarButton
        // 시트 내용 저장 Btn
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveSheet(_:)))
        navigationItem.rightBarButtonItem = saveBtn
        //self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9960784314, green: 0.5960784314, blue: 0, alpha: 1)

        // 상단 toolbar
        view.addSubview(toolBar)
        toolBar.barTintColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
        //toolBar.backgroundColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
        let tab = UIBarButtonItem()
        tab.title = "TABS"
        tab.tintColor = .white
        toolBar.setItems([tab], animated: true)
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0).isActive = true
        toolBar.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0).isActive = true
        toolBar.trailingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.trailingAnchor, multiplier: 0).isActive = true
        
    
        // spreadsheet 추가 & constraint 설정
        view.addSubview(spreadsheetView)
//        spreadsheetView.frame = CGRect(x: 0, y: 0 , width: view.frame.size.width, height: view.frame.size.height)
        spreadsheetView.translatesAutoresizingMaskIntoConstraints = false
        spreadsheetView.topAnchor.constraint(equalToSystemSpacingBelow: toolBar.bottomAnchor, multiplier: 0).isActive = true
        spreadsheetView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        spreadsheetView.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        // 스크롤 포-기

        getFiles()
        self.title = viewModel.fileName
        
        
        // chatBar
        view.addSubview(chatBar)
//        chatBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        chatBar.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        inputBtn.layer.cornerRadius = 0.25 * inputBtn.bounds.size.width
        inputText.layer.cornerRadius = 0.25 * inputText.bounds.size.height
        x.layer.cornerRadius = 0.25 * x.bounds.size.width
        y.layer.cornerRadius = 0.25 * y.bounds.size.width
        
        
        // keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: 입력 btn Action
    @IBAction func inputData(_ sender: Any) {
        // guard 문 추가 터짐 방지
        let abcIndex:Int = Int(Character(y.text!).asciiValue!)-64
        let numberIndex:Int = Int(x.text!)!
        
        if abcIndex >= 1 && abcIndex <= 26 {
            let indexPath = [abcIndex, numberIndex] as IndexPath
    //        indexPath.section = Int(x.text!)!
    //        indexPath.row = Int(y.text!)!
            spreadsheetView.selectItem(at: indexPath, animated: true, scrollPosition: ScrollPosition.init())      //지정된 인덱스 경로에서 항목을 선택하고 선택적으로 보기로 스크롤합니다.

            // 스프레드시트 뷰에 입력한 값 띄우기
            let cell = spreadsheetView.cellForItem(at: indexPath) as! SpreadsheetViewCell
            print("tField text: ", cell.tField.text!)
            cell.tField.text = inputText.text
            
            // post를 위해 spreadsheet values에 값 대입
            if viewModel.sheet?.values.count ?? 0 < numberIndex { // 가독성을 위해 비교값을 cell.row에서 numberIndex로 수정
                let lastRow = (viewModel.sheet?.values.count ?? 0) + 1
                for _ in lastRow...numberIndex {
                    viewModel.sheet?.values.append(Array(repeating: "", count: abcIndex))
                }
            }
            
            if viewModel.sheet?.values[numberIndex-1].count ?? 0 < abcIndex {
                let lastColumn = (viewModel.sheet?.values[numberIndex-1].count ?? 0) + 1
                print("abcindex",abcIndex, ", lastColumn: ",lastColumn)
                for _ in lastColumn...abcIndex {
                    viewModel.sheet?.values[numberIndex-1].append("")
                }

            }
            viewModel.sheet?.values[numberIndex-1][abcIndex-1] = inputText.text!
            print("values 배열 전체 출력: ", viewModel.sheet?.values)
            print("삽입했는지 확인. values 값!", viewModel.sheet?.values[numberIndex-1][abcIndex-1])
        } else {
            self.showToast(message: "행렬을 다시 입력하세요")
        }
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: 440, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.5, delay: 0.1, options: .curveEaseOut, animations: {
                        toastLabel.alpha = 0.0
            
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo else{ fatalError() }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{ fatalError() }
        if sender.name == UIResponder.keyboardWillShowNotification{
            let keyboardHeight = (keyboardFrame.height - view.safeAreaInsets.bottom)
            chatBar.frame.origin.y = keyboardHeight + 185
        }
        else{
            chatBar.frame.origin.y = 777 + 44
        }
        
        // 선택된 셀의 행렬값 x,y 좌표에 넣기
        guard let a = spreadsheetView.indexPathForSelectedItem else { return }
        
        let cell = spreadsheetView.cellForItem(at: a) as! SpreadsheetViewCell
        x.text = "\(a.row)"
        y.text = "\(UnicodeScalar(a.column + 64)!)"
        inputText.text = cell.tField.text
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }

    // MARK: 시트 내용 저장 Btn
    @objc func saveSheet(_ sender: Any) {
        print("Push save button")
        viewModel.postNewRow(withID: viewModel.driveFile.id, withToken: GoogleService.accessToken) { _ in
            // post 끝나고 view에 띄울 값들 정하는 부분
            self.viewModel.getSpreadsheetValues(withID: self.viewModel.driveFile.id, withToken: GoogleService.accessToken, GETorPOST: "POST") { sheet in
                guard let sheet = sheet else { return }
                print("postNewRow하고 나서 getSpreadsheetValues로 받아온 sheet: ", sheet)
                self.viewModel.sheet = sheet
                
                DispatchQueue.main.async {
                    self.spreadsheetView.reloadData()
                }
            }
        }
    }
    
    // MARK: sheet value 받아오기
    private func getFiles() {
        viewModel.getSpreadsheetValues(withID: viewModel.driveFile.id, withToken: GoogleService.accessToken, GETorPOST: "GET") { sheet in
            guard let sheet = sheet else { return }
            self.viewModel.sheet = sheet
            self.isSheetLoad = true
            
            DispatchQueue.main.async {
                self.spreadsheetView.reloadData()
            }
        }
    }
}

// MARK: SpreadsheetViewDataSource
extension SpreadsheetViewController: SpreadsheetViewDataSource {
   
    // 셀 열 몇줄
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        let colums = viewModel.sheet?.values[1].count ?? 1
        print("열 개수:", colums)
        return 70
    }
    
    // 셀 행 몇줄
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        let rows = viewModel.sheet?.values.count ?? 1
        print("행 개수", rows)
        return 100
    }
    
    // 셀 너비
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 55
        } else {
            return 125
        }
    }
    
    // 셀 높이
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        if column == 0 {
            return 32
        } else {
            return 28
        }
    }
    

    // 셀 고정     // 데이터 로드 전 값이 0이라서 고정 에러뜸
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
//    func cellForItem(at indexPath: IndexPath) -> Cell? {
//        let cell = spreadsheetView.cellForItem(at: indexPath)
//        return cell
//    }
    // 셀 내용
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let rows = viewModel.sheet?.values.count ?? 0
        
        let columns:Int!
        if let sheet = viewModel.sheet {
            var maxCount:Int = 0
            for i in 0...sheet.values.count-1 {
                if maxCount < sheet.values[i].count {
                    maxCount = sheet.values[i].count
                }
            }
            columns = maxCount
        } else { columns = 0 }
        
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: SpreadsheetViewCell.identifier, for: indexPath) as! SpreadsheetViewCell

        // 행렬 좌표명 & 기본 셀 설정
        if indexPath.row == 0 && indexPath.column == 0 { // 첫번째 셀
            cell.setupDefault(with: " ")
            cell.backgroundColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
            cell.indexPath = [indexPath.row, indexPath.column]
        } else if indexPath.row == 0 {  // 첫 열 1~N
            cell.setupDefault(with: "\(UnicodeScalar(indexPath.column + 64)!)")
            cell.backgroundColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
            cell.indexPath = [indexPath.row, indexPath.column]
        } else if indexPath.column == 0 {  // 첫 행 A~N
            cell.setupDefault(with: "\(indexPath.row)")
            cell.backgroundColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
            cell.indexPath = [indexPath.row, indexPath.column]
        } else {
            cell.setup(with: "")
            cell.indexPath = [indexPath.row, indexPath.column]
        }
        
        // 로드되면 데이터 넣기
        if self.isSheetLoad {
            if case (1...rows, 1...columns) = (indexPath.row, indexPath.column) {
                if indexPath.column - 1 < (viewModel.sheet?.values[indexPath.row - 1].count)! {
                    cell.setup(with: viewModel.sheet?.values[indexPath.row - 1][indexPath.column - 1] ?? "")
                } else {
                    cell.setup(with: "")
                }
            }
        }

        return cell
    }
}

extension SpreadsheetViewController:SpreadsheetViewDelegate {
    
}

class SpreadsheetViewCell: Cell {
    static let identifier = "sheetCell"
    var tField = UITextField()
    var indexPath = IndexPath()
    
    var row = 0
    var column = 0
    
  
    public func setup(with text:String) {
        tField.text = text
        tField.textAlignment = .left
        tField.textColor = .white
        backgroundColor = .black
        tField.isUserInteractionEnabled = false
        contentView.addSubview(tField)
    }
    
    public func setupDefault(with text:String) {
        tField.text = text
        tField.textAlignment = .center
        tField.textColor = .white
        backgroundColor  = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
        tField.isUserInteractionEnabled = false
        contentView.addSubview(tField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tField.frame = contentView.bounds
    }
  
    override var isSelected: Bool {
        didSet {
            if isSelected{
                print(indexPath)
                row = indexPath.column
                column = indexPath.row
                print(row, column)
                
                if row != 0 && column != 0{
                    layer.borderColor = #colorLiteral(red: 0.9960784314, green: 0.5960784314, blue: 0, alpha: 1).cgColor
                    layer.borderWidth = 2.0
                    tField.isUserInteractionEnabled = true
                }

            } else {
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 0.05
                tField.isUserInteractionEnabled = false
            }
        }
    }
}
