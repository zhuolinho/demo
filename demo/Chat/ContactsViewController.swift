//
//  ContactsViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/22.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ContactsViewController: UITableViewController {
    var dataSource = NSMutableArray()
    var contactsSource = NSMutableArray()
    var sectionTitles = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDataSource()
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
        else{
            return dataSource.count
        }
    }
    func reloadDataSource(){
        dataSource.removeAllObjects()
        contactsSource.removeAllObjects()
        var buddyList = EaseMob.sharedInstance().chatManager.fetchBuddyListWithError(nil)
        var buddy:EMBuddy
        for buddy in buddyList {
            if buddy.followState.value != eEMBuddyFollowState_NotFollowed.value {
                contactsSource.addObject(buddy)
            }
        }
        var loginInfo = EaseMob.sharedInstance().chatManager.loginInfo as NSDictionary
        var loginUsername:NSString?
        loginUsername = loginInfo.objectForKey(kSDKUsername) as? NSString
        if(loginUsername != nil && loginUsername?.length > 0){
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
                            var jsonResult = jsonRaw as NSDictionary
                            if jsonResult.count > 0 {
                                let result = jsonResult["result"] as NSDictionary
                                let urlWithComma = result["avatar"] as String
                                let nicknameWithComma = result["nickname"] as String
                                let url = urlWithComma.componentsSeparatedByString(",")[0]
                                let nickname = nicknameWithComma.componentsSeparatedByString(",")[0]
                                dispatch_async(dispatch_get_main_queue(), {
                                    info.updateValue(nickname, forKey: "nickname")
                                    info.updateValue(url, forKey: "avatarURL")
                                    self.dataSource.addObject(info)
                                    if(buddy.username == loginUsername!)
                                    {
                                        self.sortDataSource(self.dataSource)
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
    func sortDataSource(array: NSMutableArray){
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as UITableViewCell
        // Configure the cell...
        if indexPath.section == 0 {
            cell.imageView?.image = UIImage(named: "newFriends")
            cell.textLabel?.text = "新的朋友"
        }
        else{
            var buddy = dataSource.objectAtIndex(indexPath.row) as NSDictionary
            cell.textLabel?.text = buddy.objectForKey("nickname") as? String
            var url = buddy.objectForKey("avatarURL") as String
            let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
            let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error? == nil {
                    var rawImage: UIImage? = UIImage(data: data)
                    let img: UIImage? = rawImage
                    if img != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imageView!.image = img
                        })
                    }
                }
            })

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
