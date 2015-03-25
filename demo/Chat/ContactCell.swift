//
//  ContactCell.swift
//  demo
//
//  Created by HoJolin on 15/3/25.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    var nickname = ""
    var avatar = UIImage(named: "DefaultAvatar")
    var userName = ""
    var avatarURL = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
