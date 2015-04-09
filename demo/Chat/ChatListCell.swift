//
//  ChatListCell.swift
//  demo
//
//  Created by HoJolin on 15/3/21.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {
    var unreadLabel = UILabel(frame: CGRect(x: 42, y: 2, width: 16, height: 16))
    var avatarView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
    var detailMsg : UILabel?
    var time : UILabel?
    var name : UILabel?
    var imageURL = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        detailMsg = self.viewWithTag(2) as? UILabel
        time = self.viewWithTag(3) as? UILabel
        name =  self.viewWithTag(1) as? UILabel
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        let timeLabel = self.viewWithTag(3) as! UILabel
        let messageLabel = self.viewWithTag(2) as! UILabel
        let nameLabel = self.viewWithTag(1) as! UILabel
        self.addSubview(avatarView)
        unreadLabel.backgroundColor = UIColor.redColor()
        unreadLabel.textAlignment = NSTextAlignment.Center
        unreadLabel.textColor = UIColor.whiteColor()
        unreadLabel.layer.cornerRadius = 8
        unreadLabel.layer.masksToBounds = true
        unreadLabel.font = UIFont.systemFontOfSize(10)
        self.addSubview(unreadLabel)
        self.backgroundColor = UIColor.clearColor()
    }
}
