//
//  FriendInfoViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/25.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class FriendInfoViewController: UITableViewController, APIProtocol {
    var userName = ""
    var nickName = ""
    var avatar = UIImage(named: "DefaultAvatar")
    var avatarURL = ""
    var api = API()
    var gender = ""
    var sign = ""
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
        api.getUserInfo(userName)
        api.delegate = self
        let buddyList = EaseMob.sharedInstance().chatManager.buddyList
        var buddy = EMBuddy()
        for buddy in buddyList {
            if buddy.followState.value != eEMBuddyFollowState_NotFollowed.value && buddy.username == userName {
                navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "关注", style: UIBarButtonItemStyle.Done, target: self, action: nil), animated: true)
                println("")
            }
        }
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) as! UITableViewCell
        var avatarView = cell.viewWithTag(4) as! UIImageView
        var genderLabel = cell.viewWithTag(1) as! UILabel
        var nicknameLabel = cell.viewWithTag(2) as! UILabel
        var signLabel = cell.viewWithTag(3) as! UILabel
        nicknameLabel.text = nickName
        avatarView.image = avatar
        signLabel.text = sign
        genderLabel.text = gender
        // Configure the cell...

        return cell
    }

    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! NSDictionary
        sign = res["sign"] as! String
        gender = res["gender"] as! String
        tableView.reloadData()
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
