//
//  ApplyTableVC.swift
//  demo
//
//  Created by HoJolin on 15/4/13.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ApplyTableVC: ApplyViewController, ApplyFriendCellDelegate {
    var api = API()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "通知"
        (tabBarController as! MainTabBarController).buddyRequest = false
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

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ApplyFriendCell") as? ApplyFriendCell
        if cell == nil {
            cell = ApplyFriendCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ApplyFriendCell")
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            cell!.refuseButton.hidden = true
            cell!.addButton.setTitle("同意", forState: UIControlState.Normal)
            cell!.addButton.backgroundColor = UIColor.orangeColor()
            cell!.addButton.layer.cornerRadius = 3
            cell!.addButton.layer.masksToBounds = true
            cell!.delegate = self
        }
        if super.dataSource.count > indexPath.row {
            let entity = super.dataSource[indexPath.row] as? ApplyEntity
            if entity != nil {
                cell!.contentLabel.text = entity!.reason
                cell!.indexPath = indexPath
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let requestAvatarUrl = NSURL(string: "\(API.userInfo.host)getAvatarAndNicknameFromUid.action?userstr=\(entity!.applicantUsername)") // No such API !!!!!!!!!!!!!
                    let request: NSURLRequest = NSURLRequest(URL: requestAvatarUrl!)
                    let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error == nil {
                            var jsonRaw: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                            if (jsonRaw != nil) {
                                var jsonResult = jsonRaw as! NSDictionary
                                if jsonResult.count > 0 {
                                    let result = jsonResult["result"] as! NSDictionary
                                    let urlWithComma = result["avatar"] as! String
                    
                                    let nicknameWithComma = result["nickname"] as! String
                                    let url = urlWithComma.componentsSeparatedByString(",")[0]
                                    let nickname = nicknameWithComma.componentsSeparatedByString(",")[0]
                                    dispatch_async(dispatch_get_main_queue(), {
                                        cell!.titleLabel.text = nickname
                                    })
                                    if PicDic.picDic[url] == nil {
                                        cell!.headerImageView.image = UIImage()
                                        let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                                        let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                                        let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                            if error == nil {
                                                var rawImage: UIImage? = UIImage(data: data)
                                                let img: UIImage? = rawImage
                                                if img != nil {
                                                    dispatch_async(dispatch_get_main_queue(), {
                                                        cell!.headerImageView.image = img!
                                                        PicDic.picDic[url] = img
                                                    })
                                                }
                                                else {
                                                    cell!.headerImageView.image = UIImage(named: "DefaultAvatar")
                                                }
                                            }
                                            else {
                                                cell!.headerImageView.image = UIImage(named: "DefaultAvatar")
                                            }
                                        })
                                    }
                                    else {
                                        cell!.headerImageView.image = PicDic.picDic[url]
                                    }
                                }
                                else {
                                    cell!.headerImageView.image = UIImage(named: "DefaultAvatar")
                                }
                            }
                            else {
                                cell!.headerImageView.image = UIImage(named: "DefaultAvatar")
                            }
                        }
                        else {
                            cell!.headerImageView.image = UIImage(named: "DefaultAvatar")
                        }
                    })
                })
            }

        }
        // Configure the cell...

        return cell!
    }
    
    func applyCellAddFriendAtIndexPath(indexPath: NSIndexPath!) {
        if indexPath.row < super.dataSource.count {
            let entity = super.dataSource[indexPath.row] as! ApplyEntity
            var error = AutoreleasingUnsafeMutablePointer<EMError?>()
            EaseMob.sharedInstance().chatManager.acceptBuddyRequest(entity.applicantUsername, error: error)
            if error == nil {
                self.dataSource.removeObject(entity)
                var loginInfo = EaseMob.sharedInstance().chatManager.loginInfo as NSDictionary
                var loginUsername = loginInfo.objectForKey(kSDKUsername) as! String
                InvitationManager.sharedInstance().removeInvitation(entity, loginUser: loginUsername)
                self.tableView.reloadData()
                api.addFriend(entity.applicantUsername)
            }
            else{
                let alert = UIAlertView(title: "网络错误", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        }
        else {
            println("fuckyou")
        }
    }
    func applyCellRefuseFriendAtIndexPath(indexPath: NSIndexPath!) {
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
