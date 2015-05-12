//
//  FriendInfoViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/25.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class FriendInfoViewController: UITableViewController, APIProtocol, UIAlertViewDelegate {
    var userName = ""
    var nickName = ""
    var avatar = UIImage(named: "DefaultAvatar")
    var avatarURL = ""
    var api1 = API()
    var api2 = API()
    var sign = ""
    var uid = -1
    var isFriend = false
    var createTimes = [NSDate]()
    var contents = [String]()
    var titles = [String]()
    var charges = [Int]()
//    @IBAction func chatButtonClick(sender: UIBarButtonItem) {
//        var chatVC = ChatViewController()
//        chatVC.chatter = userName
//        chatVC.myHeadUrl = API.userInfo.imageHost + API.userInfo.profilePhotoUrl
//        chatVC.friendHeadUrl = API.userInfo.imageHost + avatarURL
//        chatVC.navigationItem.title = nickName
//        chatVC.tabBarController?.hidesBottomBarWhenPushed = true
//        self.navigationController?.viewControllers.removeAtIndex(1)
//        self.navigationController?.pushViewController(chatVC, animated: true)
//        self.navigationController?.viewControllers.removeAtIndex(1)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api1.getUserInfo(userName)
        api1.delegate = self
        api2.delegate = self
        let buddyList = EaseMob.sharedInstance().chatManager.buddyList
        var buddy = EMBuddy()
        if userName == API.userInfo.username {
            isFriend = true
        }
        else {
            for buddy in buddyList {
                if buddy.followState.value != eEMBuddyFollowState_NotFollowed.value && buddy.username == userName {
                    isFriend = true
                }
            }
        }
        let blankView = UIView(frame: CGRectZero)
        tableView.tableFooterView = blankView
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
            return titles.count
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
            var idLabel = cell.viewWithTag(1) as! UILabel
            var nicknameLabel = cell.viewWithTag(2) as! UILabel
            var signLabel = cell.viewWithTag(3) as! UILabel
            avatarView.layer.cornerRadius = 40
            avatarView.layer.masksToBounds = true
            nicknameLabel.text = nickName
            avatarView.image = avatar
            signLabel.text = sign
            idLabel.text = userName
            let attentButton = cell.viewWithTag(5) as! UIButton
            attentButton.addTarget(self, action: "addFriend", forControlEvents: UIControlEvents.TouchUpInside)
            let chatButton = cell.viewWithTag(6) as! UIButton
            if isFriend {
                attentButton.userInteractionEnabled = false
                chatButton.userInteractionEnabled = true
                chatButton.imageView?.image = UIImage(named: "user_info11_05")
                attentButton.imageView?.image = UIImage(named: "user_info11_03")
            }
            else {
                attentButton.userInteractionEnabled = true
                chatButton.userInteractionEnabled = false
                attentButton.imageView?.image = UIImage(named: "user_info1_06")
                chatButton.imageView?.image = UIImage(named: "user_info1_09")
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MissionCell", forIndexPath: indexPath) as! UITableViewCell
            let timeLabel = cell.viewWithTag(1) as! UILabel
            let titleLabel = cell.viewWithTag(2) as! UILabel
            let contentLabel = cell.viewWithTag(3) as! UILabel
            let chargeLabel = cell.viewWithTag(4) as! UILabel
            titleLabel.text = titles[indexPath.row]
            contentLabel.text = contents[indexPath.row]
            chargeLabel.text = String(charges[indexPath.row])
            let formatMission = NSDateFormatter()
            formatMission.dateFormat = "yyyy-MM-dd"
            timeLabel.text = formatMission.stringFromDate(createTimes[indexPath.row])
            return cell
        }

    }
    func addFriend() {
        let alert = UIAlertView(title: "申请好友", message: "我是...", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "发送")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            var str = alertView.textFieldAtIndex(0)?.text
            if str == "" {
                str = "请求添加好友"
            }
            var error = AutoreleasingUnsafeMutablePointer<EMError?>()
            EaseMob.sharedInstance().chatManager.addBuddy(userName, message: str, error: error)
            if error == nil {
                let alert = UIAlertView(title: "发送成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
            else {
                let alert = UIAlertView(title: "网络错误", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        }
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === api1 {
            let res = data["result"] as! NSDictionary
            sign = res["sign"] as! String
            uid = res["uid"] as! Int
            tableView.reloadData()
            api2.getMoments(uid)
        }
        else {
            let res = data["result"] as! [NSDictionary]
            for item in res {
                let charge = item["charge"] as! Int
                charges.append(charge)
                let title = item["title"] as! String
                titles.append(title)
                let content = item["content"] as! String
                contents.append(content)
                let createTime = item["createTime"] as! String
                let formatSever = NSDateFormatter()
                formatSever.timeZone = NSTimeZone(forSecondsFromGMT: 8 * 3600)
                formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
                createTimes.append(formatSever.dateFromString(createTime)!)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if(segue.identifier == "ChatSegue"){
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.chatter = userName
            chatVC.myHeadUrl = API.userInfo.imageHost + API.userInfo.profilePhotoUrl
            chatVC.friendHeadUrl = API.userInfo.imageHost + avatarURL
            chatVC.navigationItem.title = nickName
            println(self.navigationController?.viewControllers)
        }
    }
}
