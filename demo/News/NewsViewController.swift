//
//  NewsViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/12.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController, APIProtocol{
    
    var requesMore = API()
    var news = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requesMore.delegate = self
        requesMore.getMissionsAndEvidences(0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if (!API.userInfo.tokenValid && API.userInfo.token == ""){
            let mainStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let auth = mainStoryboard.instantiateInitialViewController() as UIViewController
            self.presentViewController(auth, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return news.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 2
    }
//    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }
        else if indexPath.row == 1 {
            return self.view.bounds.width
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let stuct = news[indexPath.section]["struct"] as NSDictionary
        let pics = stuct["pics"] as [NSDictionary]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as TitleCell
            cell.timeLabel.text = stuct["createTime"] as? String
            cell.nameLabel.text = stuct["nickname"] as? String
            var url = stuct["avatar"] as String
            if PicDic.picDic[url] == nil {
                let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error? == nil {
                        var rawImage: UIImage? = UIImage(data: data)
                        let img: UIImage? = rawImage
                        if img != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.avatar.image = img
                                PicDic.picDic[url] = img
                            })
                        }
                        else{
                            cell.avatar.image = UIImage(named: "DefaultAvatar")
                        }
                    }
                    else{
                        cell.avatar.image = UIImage(named: "DefaultAvatar")
                    }
                })
            }
            else {
                cell.avatar.image = PicDic.picDic[url]
            }
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MainImageCell", forIndexPath: indexPath) as MainImageCell
            let url = pics[0]["url"] as String
            cell.imageView?.clipsToBounds = true
            if PicDic.picDic[url] == nil {
                let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error? == nil {
                        var rawImage: UIImage? = UIImage(data: data)
                        let img: UIImage? = rawImage
                        if img != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.mainImageView.image = img!
                                PicDic.picDic[url] = img
                            })
                        }
                    }
                })
            }
            else {
                cell.mainImageView.image = PicDic.picDic[url]!
            }
            return cell
        }
        else {
            return UITableViewCell()
        }
        
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === requesMore {
            var res = data["result"] as NSArray
            if res.count > 0 {
                var items = [NSDictionary]()
                for it in res {
                     items.append(it as NSDictionary)
                }
                news += items
                tableView.reloadData()
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
