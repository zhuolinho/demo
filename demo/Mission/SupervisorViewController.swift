//
//  SupervisorViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/28.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class SupervisorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IChatManagerDelegate {

    var dataSource = NSMutableArray()
    var contactsSource = NSMutableArray()
    var sectionTitles = NSMutableArray()
    var sortedDataSource = NSMutableArray()
    var buddyList = NSArray()
    var delegate: StringsPass?
    var mark = [NSIndexPath : Bool]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func selectButtonClick(sender: UIButton) {
        mark[NSIndexPath(forRow: sender.tag % 1000, inSection: sender.tag / 1000)] = !mark[NSIndexPath(forRow: sender.tag % 1000, inSection: sender.tag / 1000)]!
        if mark[NSIndexPath(forRow: sender.tag % 1000, inSection: sender.tag / 1000)]! {
            sender.setImage(UIImage(named: "invite1_27"), forState: UIControlState.Normal)
        }
        else {
            sender.setImage(UIImage(named: "invite1_21"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func allButtonClick(sender: UIButton) {
        for item in mark {
            mark[NSIndexPath(forRow: item.0.row, inSection: item.0.section)] = true
        }
        tableView.reloadData()
    }
    
    
    @IBAction func inviteButtonClick(sender: UIButton) {
        var strings = "*"
        for item in mark {
            if item.1 {
                let buddy = sortedDataSource.objectAtIndex(item.0.section-1).objectAtIndex(item.0.row) as! NSDictionary
                let username = buddy.objectForKey("username") as! String
                if strings == "*" {
                    strings = username
                }
                else {
                    strings += ",\(username)"
                }
            }
        }
        delegate?.strings(strings)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        var v = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = v
        tableView.sectionIndexColor = UIColor.grayColor()
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        EaseMob.sharedInstance().chatManager.asyncFetchBuddyList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 1
        }
        else{
            return sortedDataSource.objectAtIndex(section-1).count
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return sortedDataSource.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return UITableViewCell()
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SupervisorCell", forIndexPath: indexPath) as! SupervisorCell
            var buddy = sortedDataSource.objectAtIndex(indexPath.section-1).objectAtIndex(indexPath.row) as? NSDictionary
            if buddy != nil {
                if mark[indexPath]! {
                    cell.selectButton.setImage(UIImage(named: "invite1_27"), forState: UIControlState.Normal)
                }
                else {
                    cell.selectButton.setImage(UIImage(named: "invite1_21"), forState: UIControlState.Normal)
                }
                cell.selectButton.tag = indexPath.section * 1000 + indexPath.row
                cell.nameLabel.text = buddy!.objectForKey("nickname") as? String
                cell.avatarView.layer.cornerRadius = 20
                cell.avatarView.layer.masksToBounds = true
                var url = buddy!.objectForKey("avatarURL") as! String
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
                                    cell.avatarView.image = img
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

                return cell
            }
            else {
                return UITableViewCell()
            }
        }
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
//        var loginInfo = EaseMob.sharedInstance().chatManager.loginInfo as NSDictionary
//        var loginUsername = loginInfo.objectForKey(kSDKUsername) as! String
//        if loginUsername != "" {
//            var loginBuddy = EMBuddy(username: loginUsername)
//            contactsSource.addObject(loginBuddy)
//        }
        for buddy in contactsSource{
            var info = ["username": buddy.username, "nickname": "*", "avatarURL": ""]
            if PicDic.friendDic[buddy.username] == nil {
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
                                        PicDic.friendDic[buddy.username] = ["nickname": nickname, "avatarURL": url]
                                        self.dataSource.addObject(info)
                                        if(self.dataSource.count == self.contactsSource.count)
                                        {
                                            self.sortedDataSource.addObjectsFromArray(self.sortDataSource(self.dataSource) as [AnyObject])
                                            for section in 0 ..< self.sortedDataSource.count {
                                                for i in 0 ..< self.sortedDataSource.objectAtIndex(section).count {
                                                    self.mark[NSIndexPath(forRow: i, inSection: section + 1)] = false
                                                }
                                            }
                                            self.tableView.reloadData()
                                        }
                                    })
                                }
                            }
                        }
                    })
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    let nickname = PicDic.friendDic[buddy.username]!["nickname"]
                    let url = PicDic.friendDic[buddy.username]!["avatarURL"]
                    info.updateValue(nickname, forKey: "nickname")
                    info.updateValue(url, forKey: "avatarURL")
                    self.dataSource.addObject(info)
                    if(self.dataSource.count == self.contactsSource.count)
                    {
                        self.sortedDataSource.addObjectsFromArray(self.sortDataSource(self.dataSource) as [AnyObject])
                        for section in 0 ..< self.sortedDataSource.count {
                            for i in 0 ..< self.sortedDataSource.objectAtIndex(section).count {
                                self.mark[NSIndexPath(forRow: i, inSection: section + 1)] = false
                            }
                        }
                        self.tableView.reloadData()
                    }
                })
            }
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
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || sortedDataSource.objectAtIndex(section - 1).count == 0 {
            return 0
        }
        else {
            return 20
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRectZero)
        headerView.backgroundColor = UIColor.orangeColor()
        //        headerView.tintColor = UIColor.whiteColor()
        var label = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 20))
        label.text = sectionTitles.objectAtIndex(section - 1) as? String
        label.textColor = UIColor.whiteColor()
        headerView.addSubview(label)
        return headerView
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section > 0 {
            return 60
        }
        else {
            return 0
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SupervisorCell
        mark[indexPath] = !mark[indexPath]!
        if mark[indexPath]! {
            cell.selectButton.setImage(UIImage(named: "invite1_27"), forState: UIControlState.Normal)
        }
        else {
            cell.selectButton.setImage(UIImage(named: "invite1_21"), forState: UIControlState.Normal)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
