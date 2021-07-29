//
//  DriveTableViewCell.swift
//  GoogleAPI
//
//  Created by Dmitriy Petrov on 18/10/2019.
//  Copyright © 2019 BytePace. All rights reserved.
//

import UIKit

class DriveTableViewCell: UITableViewCell {
    @IBOutlet weak var sheetImg: UIImageView!
    @IBOutlet weak var sheetName: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
}
