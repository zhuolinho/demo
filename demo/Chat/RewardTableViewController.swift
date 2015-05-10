//
//  RewardTableViewController.swift
//  demo
//
//  Created by HoJolin on 15/5/10.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class RewardTableViewController: UITableViewController {

    var reward = [NSDictionary]()
    var nickname = ""
    var myTitle = ""
    var avatar = "*"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "赏金详情"
        let blankView = UIView(frame: CGRectZero)
        tableView.tableFooterView = blankView
        getImage()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 1
        }
        else {
            return reward.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        }
        else {
            return 60
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) as! UITableViewCell
            var avatarView = cell.viewWithTag(4) as! UIImageView
            var nicknameLabel = cell.viewWithTag(2) as! UILabel
            avatarView.layer.cornerRadius = 40
            avatarView.layer.masksToBounds = true
            if PicDic.picDic[avatar] != nil {
                avatarView.image = PicDic.picDic[avatar]
            }
            else {
                avatarView.image = UIImage(named: "DefaultAvatar")
            }
            nicknameLabel.text = nickname + "的" + myTitle + "任务赏金"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MissionCell", forIndexPath: indexPath) as! UITableViewCell
//            let timeLabel = cell.viewWithTag(1) as! UILabel
            let titleLabel = cell.viewWithTag(2) as! UILabel
//            let contentLabel = cell.viewWithTag(3) as! UILabel
            let chargeLabel = cell.viewWithTag(4) as! UILabel
            titleLabel.text = reward[indexPath.row]["nickname"] as? String
//            contentLabel.text = contents[indexPath.row]
            chargeLabel.text = String(reward[indexPath.row]["rmb"] as! Int)
//            let formatMission = NSDateFormatter()
//            formatMission.dateFormat = "yyyy-MM-dd"
//            timeLabel.text = formatMission.stringFromDate(createTimes[indexPath.row])
            let avatarView = cell.viewWithTag(1) as! UIImageView
            avatarView.layer.cornerRadius = 20
            avatarView.layer.masksToBounds = true
            let avatar = reward[indexPath.row]["avatar"] as! String
            if PicDic.picDic[avatar] != nil {
                avatarView.image = PicDic.picDic[avatar]
            }
            else {
                avatarView.image = UIImage(named: "DefaultAvatar")
            }
            return cell
        }
    }
    
    func getImage() {
        var rewards = reward
        let master = ["avatar": avatar]
        rewards.append(master)
        for item in rewards {
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
