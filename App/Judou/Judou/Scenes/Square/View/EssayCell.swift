//
//  EssayCell.swift
//  Judou
//
//  Created by 4work on 2018/12/22.
//  Copyright © 2018 Sam Cooper Studio. All rights reserved.
//

import UIKit

class EssayCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: -
    deinit {
        Log("deinit \(self.classForCoder)")
    }
}
