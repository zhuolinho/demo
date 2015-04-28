//
//  SupervisorCell.swift
//  demo
//
//  Created by HoJolin on 15/4/28.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class SupervisorCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var avatarView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
