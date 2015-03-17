//
//  ChatTableViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/16.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {

    var emChatListVC = ChatListViewController()
    var conversations = NSMutableArray()
    
    func refreshDataSource() {
        self.conversations = emChatListVC.loadDataSource()
        tableView.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        self.refreshDataSource()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return conversations.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatTabelCell", forIndexPath: indexPath) as UITableViewCell
        let row = indexPath.row
        let conversation = conversations[row] as EMConversation
        var unreadCount = emChatListVC.unreadMessageCountByConversation(conversation)
        let username = conversation.chatter
        let timeLabel = cell.viewWithTag(3) as UILabel
        let messageLabel = cell.viewWithTag(2) as UILabel
        let nameLabel = cell.viewWithTag(1) as UILabel
        var avatarUrl = ""
        timeLabel.text = emChatListVC.lastMessageTimeByConversation(conversation)
        messageLabel.text = emChatListVC.subTitleMessageByConversation(conversation)
        // Configure the cell...
        var avatarView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        cell.addSubview(avatarView)
        var unreadLabel = UILabel(frame: CGRect(x: 42, y: 2, width: 16, height: 16))
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let requestAvatarUrl = NSURL(string: "\(API.userInfo.host)getAvatarAndNicknameFromUid.action?userstr=\(username)") // No such API !!!!!!!!!!!!!
            let request: NSURLRequest = NSURLRequest(URL: requestAvatarUrl!)
            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    var jsonRaw: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    if (jsonRaw != nil) {
                        var jsonResult = jsonRaw as NSDictionary
                        if jsonResult.count > 0 {
                            let result = jsonResult["result"] as NSDictionary
                            let urlWithComma = result["avatar"] as String
                            let nicknameWithComma = result["nickname"] as String
                            let url = urlWithComma.componentsSeparatedByString(",")[0]
                            let nickname = nicknameWithComma.componentsSeparatedByString(",")[0]
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                nameLabel.text = nickname
                                avatarUrl = url
                            })
                            let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                            let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                if error? == nil {
                                    var rawImage: UIImage? = UIImage(data: data)
                                    let img: UIImage? = rawImage
                                    if img != nil {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            avatarView.image = img!
                                        })
                                    }
                                    avatarView.image = UIImage(named: "DefaultAvatar")
                                    
                                }
                                avatarView.image = UIImage(named: "DefaultAvatar")
                                
                            })
                        } else {
                            avatarView.image = UIImage(named: "DefaultAvatar")
                        }
                    } else {
                        avatarView.image = UIImage(named: "DefaultAvatar")
                    }
                    
                } else {
                    avatarView.image = UIImage(named: "DefaultAvatar")
                }
            })
        })
        unreadLabel.backgroundColor = UIColor.redColor()
        unreadLabel.text = "\(unreadCount)"
        unreadLabel.textAlignment = NSTextAlignment.Center
        unreadLabel.textColor = UIColor.whiteColor()
        unreadLabel.layer.cornerRadius = 8
        unreadLabel.layer.masksToBounds = true
        if unreadCount>0{
            if (unreadCount < 9) {
                unreadLabel.font = UIFont.systemFontOfSize(13)
            }else if unreadCount > 9 && unreadCount <= 99 {
                unreadLabel.font = UIFont.systemFontOfSize(10)
            }else{
                unreadLabel.font = UIFont.systemFontOfSize(7)
            }
            cell.addSubview(unreadLabel)
        }
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
