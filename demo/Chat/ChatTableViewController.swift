//
//  ChatTableViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/16.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController, IChatManagerDelegate {

    var emChatListVC = ChatListViewController()
    var conversations = NSMutableArray()
    
    func refreshDataSource() {
        self.conversations = emChatListVC.loadDataSource()
        if self.conversations.count > 0 {
            self.conversations.sortUsingComparator({ (obj1, obj2) -> NSComparisonResult in
                var msg1 = (obj1 as EMConversation).latestMessage()
                var msg2 = (obj2 as EMConversation).latestMessage()
                if msg1 == nil {
                    if msg2 == nil {
                        return NSComparisonResult.OrderedSame
                    } else {
                        return NSComparisonResult.OrderedDescending
                    }
                } else {
                    if msg2 == nil {
                        return NSComparisonResult.OrderedAscending
                    } else {
                        if msg1.timestamp > msg2.timestamp {
                            return NSComparisonResult.OrderedAscending
                        } else if msg1.timestamp < msg2.timestamp {
                            return NSComparisonResult.OrderedDescending
                        } else {
                            return NSComparisonResult.OrderedSame
                        }
                    }
                }
            })
        }
        tableView.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        self.refreshDataSource()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        didUnreadMessagesCountChanged()
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
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
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let row = indexPath.row
            let conversation = self.conversations[row] as EMConversation
            EaseMob.sharedInstance().chatManager.removeConversationByChatter!(conversation.chatter, deleteMessages: true)
            self.conversations.removeObjectAtIndex(row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return conversations.count
    }

    func didUnreadMessagesCountChanged() {
        self.refreshDataSource()
        self.setupUnreadMessageCount()
        
    }

    func setupUnreadMessageCount() {
        var conversations = EaseMob.sharedInstance().chatManager.conversations
        var unreadCount: Int = 0
        for item in conversations! {
            let conversation = item as EMConversation
            unreadCount += Int(conversation.unreadMessagesCount())
        }
        let vc = self.tabBarController!.viewControllers![2] as UIViewController
        if unreadCount > 0 {
            vc.tabBarItem.badgeValue = String(unreadCount)
            UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCount
        }
        else {
            vc.tabBarItem.badgeValue = nil
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatTabelCell", forIndexPath: indexPath) as ChatListCell
        let row = indexPath.row
        if row % 2 == 1 {
            cell.backgroundColor = UIColor.whiteColor()
        }
        else {
            cell.backgroundColor = UIColor.clearColor()
        }
        let conversation = conversations[row] as EMConversation
        var unreadCount = emChatListVC.unreadMessageCountByConversation(conversation)
        let username = conversation.chatter
        cell.time?.text = emChatListVC.lastMessageTimeByConversation(conversation)
        cell.detailMsg?.text = emChatListVC.subTitleMessageByConversation(conversation)
        cell.unreadLabel.text = "\(unreadCount)"
        if unreadCount == 0{
            cell.unreadLabel.hidden = true
        }
        else{
            cell.unreadLabel.hidden = false
        }
        // Configure the cell...
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
                                cell.name?.text = nickname
                                cell.imageURL = url
                            })
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
                                                cell.avatarView.image = img!
                                                PicDic.picDic[url] = img
                                            })
                                        }
                                        else {
                                            cell.avatarView.image = UIImage(named: "DefaultAvatar")
                                        }
                                    }
                                    else {
                                        cell.avatarView.image = UIImage(named: "DefaultAvatar")
                                    }
                                })
                            }
                            else {
                                cell.avatarView.image = PicDic.picDic[url]
                            }
                        }
                        else {
                            cell.avatarView.image = UIImage(named: "DefaultAvatar")
                        }
                    }
                    else {
                        cell.avatarView.image = UIImage(named: "DefaultAvatar")
                    }
                }
                else {
                    cell.avatarView.image = UIImage(named: "DefaultAvatar")
                }
            })
        })
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


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "CellSegue"){
            let cell = sender as ChatListCell
            let indexPath = tableView.indexPathForCell(cell)
            let row = indexPath!.row
            let conversation = self.conversations[row] as EMConversation
            let chatVC = segue.destinationViewController as ChatViewController
            chatVC.chatter = conversation.chatter
            chatVC.myHeadUrl = API.userInfo.imageHost + API.userInfo.profilePhotoUrl
            chatVC.friendHeadUrl = API.userInfo.imageHost + cell.imageURL
            chatVC.buyCourseRightNow = false
            chatVC.navigationItem.title = (sender as ChatListCell).name?.text
            conversation.markAllMessagesAsRead(true)
        }
    }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

}
