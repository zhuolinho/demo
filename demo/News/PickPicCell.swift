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
        let cell = pickCollectionView.dequeueReusableCellWithReuseIdentifier("PickCollectionCell", forIndexPath: indexPath) as UICollectionViewCell
        let imageView = cell.viewWithTag(1) as UIImageView
        let url = dataSource[indexPath.row]["url"] as String
        if PicDic.picDic[url] == nil {
            imageView.image = UIImage()
            let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
            let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error? == nil {
                    var rawImage: UIImage? = UIImage(data: data)
                    let img: UIImage? = rawImage
                    if img != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            imageView.image = img!
                            PicDic.picDic[url] = img
                        })
                    }
                }
            })
        }
        else {
            imageView.image = PicDic.picDic[url]!
        }
        return cell
    }
}
