//
//  Status Cell.swift
//  demo
//
//  Created by HoJolin on 15/4/3.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class StatusCell: UITableViewCell {
    @IBOutlet weak var superviseButton: UIButton!

    @IBOutlet weak var wtfLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var evidentState: UILabel!
    @IBOutlet weak var meneyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
