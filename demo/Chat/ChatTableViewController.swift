//
//  ChatTableViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/16.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController, IChatManagerDelegate, APIProtocol {

    var emChatListVC = ChatListViewController()
    var conversations = NSMutableArray()
    let api = API()
    var unreadCommentNum = 0
    var unreadMissionNum = 0
    
    func refreshDataSource() {
        self.conversations = emChatListVC.loadDataSource()
        if self.conversations.count > 0 {
            self.conversations.sortUsingComparator({ (obj1, obj2) -> NSComparisonResult in
                var msg1 = (obj1 as! EMConversation).latestMessage()
                var msg2 = (obj2 as! EMConversation).latestMessage()
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
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    override func viewWillAppear(animated: Bool) {
        if unreadCommentNum == 0 || unreadMissionNum == 0 {
            api.getMyInfo()
        }
        refreshDataSource()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        api.delegate = self
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
            let conversation = self.conversations[row] as! EMConversation
            EaseMob.sharedInstance().chatManager.removeConversationByChatter!(conversation.chatter, deleteMessages: true)
            self.conversations.removeObjectAtIndex(row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 3
        }
        else {
            return conversations.count
        }
    }

    func didUnreadMessagesCountChanged() {
        self.refreshDataSource()
//        self.setupUnreadMessageCount()
        
    }
    func didReceiveBuddyRequest(username: String!, message: String!) {
        self.refreshDataSource()
    }
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "删除"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatTabelCell", forIndexPath: indexPath) as! ChatListCell
            let row = indexPath.row
            let conversation = conversations[row] as! EMConversation
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
            if PicDic.friendDic[username] == nil {
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let requestAvatarUrl = NSURL(string: "\(API.userInfo.host)getAvatarAndNicknameFromUid.action?userstr=\(username)") // No such API !!!!!!!!!!!!!
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
                                        cell.name?.text = nickname
                                        cell.imageURL = url
                                        PicDic.friendDic[username] = ["nickname": nickname, "avatarURL": url]
                                    })
                                    if PicDic.picDic[url] == nil {
                                        cell.avatarView.image = UIImage()
                                        let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                                        let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                                        let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                            if error == nil {
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
            }
            else {
                let url = PicDic.friendDic[username]!["avatarURL"]!
                cell.name?.text = PicDic.friendDic[username]!["nickname"]
                if PicDic.picDic[url] == nil {
                    cell.avatarView.image = UIImage()
                    let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                    let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                    let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error == nil {
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
            return cell
        }
        else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("Coment", forIndexPath: indexPath) as! SystemCell
                cell.unreadLabel.hidden = unreadCommentNum == 0
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("MissionInfo", forIndexPath: indexPath) as! SystemCell
                cell.unreadLabel.hidden = unreadMissionNum == 0
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("Nonification", forIndexPath: indexPath) as! SystemCell
                cell.unreadLabel.hidden = !(tabBarController as! MainTabBarController).buddyRequest
                return cell
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            unreadCommentNum = 0
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            unreadMissionNum = 0
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        if indexPath.section == 1 {
            return true
        }
        else {
            return false
        }
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        println(errno)
    }

    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! NSDictionary
        unreadCommentNum = res["unreadCommentNum"] as! Int
        unreadMissionNum = res["unreadMissionNum"] as! Int
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
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
            let cell = sender as! ChatListCell
            let indexPath = tableView.indexPathForCell(cell)
            let row = indexPath!.row
            let conversation = self.conversations[row] as! EMConversation
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.chatter = conversation.chatter
            chatVC.myHeadUrl = API.userInfo.imageHost + API.userInfo.profilePhotoUrl
            chatVC.friendHeadUrl = API.userInfo.imageHost + cell.imageURL
            chatVC.buyCourseRightNow = false
            chatVC.nickname = cell.name?.text
            chatVC.url = cell.imageURL
            chatVC.navigationItem.title = (sender as! ChatListCell).name?.text
            chatVC.delegate = navigationController as! MainNavigationController
            conversation.markAllMessagesAsRead(true)
        }
    }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

}
