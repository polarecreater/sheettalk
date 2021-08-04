//
//  Spreadsheet.swift
//  GoogleAPI
//
//  Created by Dmitriy Petrov on 18/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

struct Spreadsheet: Decodable {
    var spreadsheetId: String
    var valueRanges: [ValueRange]
}

struct ValueRange: Decodable {
    var range: String
    var majorDimension: String
    var values: [[String]]
}
