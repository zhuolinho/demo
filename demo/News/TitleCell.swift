//
//  TitleCell.swift
//  demo
//
//  Created by HoJolin on 15/3/30.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class TitleCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
