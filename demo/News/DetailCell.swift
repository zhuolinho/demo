//
//  DetailCell.swift
//  demo
//
//  Created by HoJolin on 15/4/3.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
