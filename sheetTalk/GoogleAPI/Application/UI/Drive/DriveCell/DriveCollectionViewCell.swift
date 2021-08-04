//
//  DriveCollectionViewCell.swift
//  GoogleAPI
//
//  Created by 황윤경 on 2021/07/24.
//  Copyright © 2021 BytePace. All rights reserved.
//

import UIKit

class DriveCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var sheetName: UILabel!
    @IBOutlet weak var sheetImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // cell 모서리 둥글게
        self.layer.cornerRadius = 10
    }

    @IBAction func sheetEtcBtn(_ sender: Any) {
        print("즐겨찾기, 공유 등 추가")
    }
}
