//
//  MissionNotificationTableVC.swift
//  demo
//
//  Created by HoJolin on 15/4/23.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MissionNotificationTableVC: UITableViewController, APIProtocol {

    let api = API()
    var notifications = [NSDictionary]()
    let setRead = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        let blankView = UIView()
        tableView.tableFooterView = blankView
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        api.getNotification(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return notifications.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        println(errno)
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        notifications = data["result"] as! [NSDictionary]
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        for item in notifications {
            let url = item["avatar"] as! String
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MissionNotificationCell", forIndexPath: indexPath) as! MissionNotificationCell

        // Configure the cell...
        
        let avatarView = cell.viewWithTag(1) as! UIImageView
        let contentLabel = cell.viewWithTag(2) as! UILabel
        let timeLabel = cell.viewWithTag(3) as! UILabel
        
        if PicDic.picDic[notifications[indexPath.section]["avatar"] as! String] == nil {
            avatarView.image = UIImage(named: "DefaultAvatar")
        }
        else {
            avatarView.image = PicDic.picDic[notifications[indexPath.section]["avatar"] as! String]
        }
        contentLabel.text = notifications[indexPath.section]["content"] as? String
        timeLabel.text = friendlyTime(notifications[indexPath.section]["createTime"] as! String)
        
        if notifications[indexPath.section]["readFlag"] as! Int == 1 {
            cell.unreadLabel.hidden = true
        }
        else {
            cell.unreadLabel.hidden = false
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(notifications[indexPath.section])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        setRead.readMissionNotification(notifications[indexPath.section]["id"] as! Int)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MissionNotificationCell
        cell.unreadLabel.hidden = true
        if notifications[indexPath.section]["type"] as! Int == 1 {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("MissionDetailVC") as! MissionDetailVC
            vc.mid = notifications[indexPath.section]["mid"] as! Int
            navigationController?.pushViewController(vc, animated: true)
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
