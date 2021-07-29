//
//  SheetProperties.swift
//  GoogleAPI
//
//  Created by 석민솔 on 2021/07/28.
//  Copyright © 2021 BytePace. All rights reserved.
//

// get으로 spreadsheet 내 sheet properties를 읽어오기 위한 코드


struct getProperties: Decodable {
    var sheets: [Sheet]
}

// Spreadsheet > sheet obj.
struct Sheet: Decodable {
    var properties: [Property]
    var data: [GridData] // 시트의 widthForColumn, heightForRow 정하려고 가져옴
}

// Spreadsheet > Sheet obj. > SheetProperties obj.
struct Property: Decodable {
//    var sheetId: Int    // 시트 탭별 아이디(링크에서 아이디 뒤에 뜨는 /edit#gid=1705583353 이부분)
    var title: String   // 시트 탭별 제목(batchGet으로 sheetValue 받아올 때 range 설정용, tabbar button 구현시에 값으로 사용)
    var index: Int      // 시트 인덱스(0, 1, 2 ...)
}

// Spreadsheet > Sheet obj. > GridData obj.
struct GridData: Decodable {
    var rowMetadata: [rowDimensionProperty]
    var columnMetadata: [columnDimensionProperty]
}

// Spreadsheet > Sheet obj. > GridData obj. > DimensionProperty obj.
struct rowDimensionProperty:Decodable {
    var pixelSize: Int // 셀의 높이height 알 수 있는 변수
}

struct columnDimensionProperty:Decodable {
    var pixelSize: Int // 셀의 넓이width 알 수 있는 변수
}
