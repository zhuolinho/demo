//
//  MainImageCell.swift
//  demo
//
//  Created by HoJolin on 15/3/31.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MainImageCell: UITableViewCell {

    @IBOutlet weak var countLabel: UILabel!

    @IBOutlet weak var mainImageView: UIImageView!
    var photosData = [NSDictionary]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
