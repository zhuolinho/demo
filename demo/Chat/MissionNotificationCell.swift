//
//  MissionNotificationCell.swift
//  demo
//
//  Created by HoJolin on 15/4/23.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MissionNotificationCell: UITableViewCell {

    var unreadLabel = UILabel(frame: CGRect(x: 45, y: 5, width: 10, height: 10))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        let avatar = viewWithTag(1) as! UIImageView
        avatar.layer.cornerRadius = 5
        avatar.layer.masksToBounds = true
        unreadLabel.backgroundColor = UIColor.redColor()
        unreadLabel.layer.cornerRadius = 5
        unreadLabel.layer.masksToBounds = true
        self.addSubview(unreadLabel)
    }
    
}
