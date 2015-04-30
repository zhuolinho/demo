//
//  PickPicCell.swift
//  demo
//
//  Created by HoJolin on 15/3/31.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class PickPicCell: UITableViewCell, UICollectionViewDataSource {

    @IBOutlet weak var pickCollectionView: UICollectionView!
    var dataSource = [NSDictionary]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickCollectionView.dataSource = self
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = pickCollectionView.dequeueReusableCellWithReuseIdentifier("PickCollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
        let imageView = cell.viewWithTag(1) as! UIImageView
        let url = dataSource[indexPath.row]["url"] as! String
        if PicDic.picDic[url] == nil {
            imageView.image = UIImage(named: "noimage2")
        }
        else {
            imageView.image = PicDic.picDic[url]
        }
        return cell
    }
}
