//
//  ContactsViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/22.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ContactsViewController: UITableViewController, IChatManagerDelegate {
    var dataSource = NSMutableArray()
    var contactsSource = NSMutableArray()
    var sectionTitles = NSMutableArray()
    var sortedDataSource = NSMutableArray()
    var buddyList = NSArray()
    let api = API()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        EaseMob.sharedInstance().chatManager.asyncFetchBuddyList()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        var v = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = v
        tableView.sectionIndexColor = UIColor.grayColor()
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
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
        return sortedDataSource.count+1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 1
        }
        else{
            return sortedDataSource.objectAtIndex(section-1).count
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "删除"
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            var loginInfo = EaseMob.sharedInstance().chatManager.loginInfo as NSDictionary
            var loginUsername = loginInfo.objectForKey(kSDKUsername) as! String
            var buddy = sortedDataSource.objectAtIndex(indexPath.section - 1).objectAtIndex(indexPath.row) as! NSDictionary
            var username = buddy["username"] as! String
            if username == loginUsername {
                var alert = UIAlertView(title: "提示", message: "不能删除自己", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                return
            }
            tableView.beginUpdates()
            sortedDataSource.objectAtIndex(indexPath.section - 1).removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var error = AutoreleasingUnsafeMutablePointer<EMError?>()
                EaseMob.sharedInstance().chatManager.removeBuddy(username, removeFromRemote: true, error: error)
                if error == nil {
                    EaseMob.sharedInstance().chatManager.removeConversationByChatter?(username, deleteMessages: true)
                    self.api.deleteFriend(username)
                }
            })
        }
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    func didFetchedBuddyList(buddyList: [AnyObject]!, error: EMError!) {
        if error == nil {
            self.buddyList = buddyList
            reloadDataSource()
        }
    }
    func reloadDataSource(){
        dataSource.removeAllObjects()
        contactsSource.removeAllObjects()
        sortedDataSource.removeAllObjects()

        var buddy:EMBuddy
        for buddy in buddyList {
            if buddy.followState.value != eEMBuddyFollowState_NotFollowed.value {
                contactsSource.addObject(buddy)
            }
        }
        var loginInfo = EaseMob.sharedInstance().chatManager.loginInfo as NSDictionary
        var loginUsername = loginInfo.objectForKey(kSDKUsername) as! String
        if loginUsername != "" {
            var loginBuddy = EMBuddy(username: loginUsername)
            contactsSource.addObject(loginBuddy)
        }
        for buddy in contactsSource{
            var info = ["username": buddy.username, "nickname": "*", "avatarURL": ""]
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let requestAvatarUrl = NSURL(string: "\(API.userInfo.host)getAvatarAndNicknameFromUid.action?userstr=\(buddy.username)") // No such API !!!!!!!!!!!!!
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
                                    info.updateValue(nickname, forKey: "nickname")
                                    info.updateValue(url, forKey: "avatarURL")
                                    self.dataSource.addObject(info)
                                    if(self.dataSource.count == self.contactsSource.count)
                                    {
                                        self.sortedDataSource.addObjectsFromArray(self.sortDataSource(self.dataSource) as [AnyObject])
                                        self.tableView.reloadData()
                                    }
                                })
                            }
                        } 
                    }
                })
            })
        }
    }
    func sortDataSource(dataArray: NSMutableArray) -> NSArray{
        var indexCollation = UILocalizedIndexedCollation.currentCollation() as! UILocalizedIndexedCollation
        self.sectionTitles.removeAllObjects()
        self.sectionTitles.addObjectsFromArray(indexCollation.sectionTitles)
        var highSection = self.sectionTitles.count
        var sortedArray = NSMutableArray(capacity: 1)
        for(var i = 0; i <= highSection; i++){
            var sectionArray = NSMutableArray(capacity: 1)
            sortedArray.addObject(sectionArray)
        }
        var buddy : NSDictionary
        for buddy in dataArray {
            var firstLetter = ChineseToPinyin.pinyinFromChineseString(buddy.objectForKey("nickname") as! String)
            var section = indexCollation.sectionForObject(firstLetter.substringToIndex(advance(firstLetter.startIndex, 1)), collationStringSelector: "uppercaseString")
            var array = sortedArray.objectAtIndex(section) as! NSMutableArray
            array.addObject(buddy)
        }
        for(var i = 0; i < sortedArray.count; i++){
            var array = sortedArray.objectAtIndex(i).sortedArrayUsingComparator({
                (obj1: AnyObject!, obj2: AnyObject!) -> NSComparisonResult in
                    var firstLetter1 = ChineseToPinyin.pinyinFromChineseString(obj1.objectForKey("nickname")as! String)
                    var firstLetter2 = ChineseToPinyin.pinyinFromChineseString(obj2.objectForKey("nickname")as! String)
                return firstLetter1.caseInsensitiveCompare(firstLetter2)
            })
            sortedArray.replaceObjectAtIndex(i, withObject: NSMutableArray(array: array))
        }
        return sortedArray
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Configure the cell...
        var imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewFriendsCell", forIndexPath: indexPath) as! UITableViewCell
            if indexPath.row == 0 {
                imageView.image = UIImage(named: "newFriends")
                var label = view.viewWithTag(2) as! UILabel
                label.text = "新的朋友"
                cell.addSubview(imageView) 
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
            var buddy = sortedDataSource.objectAtIndex(indexPath.section-1).objectAtIndex(indexPath.row) as? NSDictionary
            if buddy != nil {
                var label = view.viewWithTag(1) as! UILabel
                label.text = buddy!.objectForKey("nickname") as? String
                cell.nickname = label.text!
                cell.userName = buddy!.objectForKey("username") as! String
                cell.addSubview(imageView)
                var url = buddy!.objectForKey("avatarURL") as! String
                cell.avatarURL = url
                if PicDic.picDic[url] == nil {
                    cell.avatar = UIImage()
                    let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                    let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                    let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error == nil {
                            var rawImage: UIImage? = UIImage(data: data)
                            let img: UIImage? = rawImage
                            if img != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    imageView.image = img
                                    cell.avatar = img
                                    PicDic.picDic[url] = img
                                })
                            }
                            else{
                                imageView.image = UIImage(named: "DefaultAvatar")
                            }
                        }
                        else{
                            imageView.image = UIImage(named: "DefaultAvatar")
                        }
                    })
                }
                else {
                    imageView.image = PicDic.picDic[url]
                    cell.avatar = PicDic.picDic[url]
                }
                return cell
            }
            else {
                return UITableViewCell()
            }
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || sortedDataSource.objectAtIndex(section - 1).count == 0 {
            return 0
        }
        else {
            return 20
        }
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRectZero)
        headerView.backgroundColor = UIColor.orangeColor()
//        headerView.tintColor = UIColor.whiteColor()
        var label = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 20))
        label.text = sectionTitles.objectAtIndex(section - 1) as? String
        label.textColor = UIColor.whiteColor()
        headerView.addSubview(label)
        return headerView
    }
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if(section == 0 || sortedDataSource.objectAtIndex(section-1).count == 0){
//            return nil
//        }
//        else{
//            return self.sectionTitles.objectAtIndex(section - 1)as? String
//        }
//    }
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]{
        var existTitles = NSMutableArray()
        existTitles.addObject("?")
        for(var i = 0; i < sectionTitles.count; i++){
            if(sortedDataSource.objectAtIndex(i).count > 0){
                existTitles.addObject(sectionTitles.objectAtIndex(i))
            }
        }
        return existTitles as [AnyObject]
    }


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
        if segue.identifier == "ContactSegue" {
            var cell = sender as! ContactCell
            var friendInfoVC = segue.destinationViewController as! FriendInfoViewController
            friendInfoVC.nickName = cell.nickname
            friendInfoVC.userName = cell.userName
            friendInfoVC.avatar = cell.avatar
            friendInfoVC.avatarURL = cell.avatarURL
        }
    }
}
