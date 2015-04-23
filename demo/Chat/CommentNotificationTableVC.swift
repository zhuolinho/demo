//
//  CommentNotificationTableVC.swift
//  demo
//
//  Created by HoJolin on 15/4/23.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class CommentNotificationTableVC: UITableViewController, APIProtocol {

    let api = API()
    var CommentNotification = [NSDictionary]()
    let markRead = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        api.getCommentNotification(0)
        let blankView = UIView()
        tableView.tableFooterView = blankView
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return CommentNotification.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        CommentNotification = data["result"] as! [NSDictionary]
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        for item in CommentNotification {
            markRead.readCommentNotification(item["id"] as! Int)
            let avatar = item["avatar"] as! String
            var pics = [String]()
            pics.append(avatar)
            pics.append(item["pic"] as! String)
            for url in pics {
                if PicDic.picDic[url] == nil {
                    let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                    let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                    let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error == nil {
                            var rawImage: UIImage? = UIImage(data: data)
                            let img: UIImage? = rawImage
                            if img != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    PicDic.picDic[url] = img
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MissionDetailVC") as! MissionDetailVC
//        if news[indexPath.section]["type"] as! String == "mission" {
            vc.mid = CommentNotification[indexPath.section]["mid"] as! Int
            vc.initNum = 0
//        }
//        else {
//            vc.initNum = 1
//            vc.mid = sturt["mid"] as! Int
//        }
        if indexPath.row != 6 {
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        println(errno)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentNotificationCell", forIndexPath: indexPath) as! UITableViewCell
        let avatar = cell.viewWithTag(1) as! UIImageView
        let missionImage = cell.viewWithTag(2) as! UIImageView
        let nicknameLabel = cell.viewWithTag(3) as! UILabel
        let content = cell.viewWithTag(4) as! UILabel
        let timeLabel = cell.viewWithTag(5) as! UILabel
        avatar.layer.cornerRadius = 5
        avatar.layer.masksToBounds = true
        if PicDic.picDic[CommentNotification[indexPath.section]["avatar"] as! String] == nil {
            avatar.image = UIImage(named: "DefaultAvatar")
        }
        else {
            avatar.image = PicDic.picDic[CommentNotification[indexPath.section]["avatar"] as! String]
        }
        if PicDic.picDic[CommentNotification[indexPath.section]["pic"] as! String] == nil {
            missionImage.image = UIImage()
        }
        else {
            missionImage.image = PicDic.picDic[CommentNotification[indexPath.section]["pic"] as! String]
        }
        nicknameLabel.text = CommentNotification[indexPath.section]["nickname"] as? String
        content.text = CommentNotification[indexPath.section]["content"] as? String
        timeLabel.text = CommentNotification[indexPath.section]["createTime"] as? String
        // Configure the cell...

        return cell
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
