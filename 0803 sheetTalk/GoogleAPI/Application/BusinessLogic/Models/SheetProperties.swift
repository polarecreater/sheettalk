//
//  SheetProperties.swift
//  GoogleAPI
//
//  Created by 석민솔 on 2021/07/28.
//  Copyright © 2021 BytePace. All rights reserved.
//

// get으로 spreadsheet 내 sheet properties를 읽어오기 위한 코드


// MARK: - GetProperties
struct GetProperties: Decodable {
    var sheets: [Sheet]?

    enum CodingKeys: String, CodingKey {
        case sheets
    }
}

// MARK: - Sheet
struct Sheet: Decodable {
    var properties: SheetProperties?
    var data: [GridData]?
}

// MARK: - SheetProperties
struct SheetProperties: Decodable {
//    var sheetID: Int?
    var title: String? // 받아올 값
    var index: Int?
//    let sheetType: String?
//    let gridProperties: GridProperties?

    enum CodingKeys: String, CodingKey {
        case title, index
    }
}

// MARK: - GridData
struct GridData: Decodable {
    var columnMetadata: [DimensionProperties]?
}

// MARK: - DimensionProperties
struct DimensionProperties: Decodable {
    var pixelSize: Int?
}
