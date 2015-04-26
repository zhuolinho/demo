
//
//  InviteCell.swift
//  demo
//
//  Created by HoJolin on 15/4/26.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class InviteCell: UITableViewCell {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
