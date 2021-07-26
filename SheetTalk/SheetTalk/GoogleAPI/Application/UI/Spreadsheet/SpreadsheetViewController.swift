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
    var isSheetLoad = false
    private let spreadsheetView = SpreadsheetView()
    
    var viewModel: SpreadsheetViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        spreadsheetView.register(SpreadsheetViewCell.self, forCellWithReuseIdentifier: SpreadsheetViewCell.identifier)
        spreadsheetView.dataSource = self

        navigationController?.navigationBar.prefersLargeTitles = false
        
        getFiles()
        
        view.addSubview(spreadsheetView)
        self.title = viewModel.fileName
    }
    
    override func viewDidLayoutSubviews() { // 시트 레이아웃 constraint
        super.viewDidLayoutSubviews()
        
        spreadsheetView.frame = CGRect(x: 0, y: 0 , width: view.frame.size.width, height: view.frame.size.height)
        
        
    }
    
    private func getFiles() {
        viewModel.getSpreadsheet(withID: viewModel.driveFile.id, withToken: GoogleService.accessToken) { sheet in
            guard let sheet = sheet else { return }
            self.viewModel.sheet = sheet
            self.isSheetLoad = true
            
            DispatchQueue.main.async {
                self.spreadsheetView.reloadData()
            }
        }
    }
}

//extension SpreadsheetViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.sheet?.values.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellIdentifier = "SpreadsheetViewCell"
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SpreadsheetViewCell else {
//            fatalError()
//        }
//        let sheet = viewModel.sheet?.values[indexPath.row]
//
//        if indexPath.row == 0 {
//            cell.backgroundColor = .lightGray
//        }
//
//        cell.nameLabel.text = sheet?[0]
//        cell.priceLabel.text = sheet?[1]
//        cell.dateLabel.text = sheet?[2]
//
//        return cell
//    }
//}

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


    // 셀 내용
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let rows = viewModel.sheet?.values.count ?? 0
        let columns = viewModel.sheet?.values[1].count ?? 0
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: SpreadsheetViewCell.identifier, for: indexPath) as! SpreadsheetViewCell

        // 행렬 좌표명 & 기본 셀 설정
        if indexPath.row == 0 && indexPath.column == 0 { // 첫번째 셀
            cell.setupDefault(with: " ")
            cell.backgroundColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
        } else if indexPath.row == 0 {  // 첫 열 1~N
            cell.setupDefault(with: "\(UnicodeScalar(indexPath.column + 64)!)")
            cell.backgroundColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
        } else if indexPath.column == 0 {  // 첫 행 A~N
            cell.setupDefault(with: "\(indexPath.row)")
            cell.backgroundColor = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
        } else {
            cell.setup(with: "")
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
class SpreadsheetViewCell: Cell {
    static let identifier = "sheetCell"
    let label = UILabel()
  
    public func setup(with text:String) {
        label.text = text
        label.textAlignment = .left
        label.textColor = .white
        backgroundColor = .black
        contentView.addSubview(label)
    }
    
    public func setupDefault(with text:String) {
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        backgroundColor  = #colorLiteral(red: 0.187317878, green: 0.1923363805, blue: 0.2093544602, alpha: 1)
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
}
