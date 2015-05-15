//
//  CommentNotificationTableVC.swift
//  demo
//
//  Created by HoJolin on 15/4/23.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class CommentNotificationTableVC: UITableViewController, APIProtocol, UITextFieldDelegate {

    let api = API()
    var CommentNotification = [NSDictionary]()
    let markRead = API()
    var type = 0
    var talkerUsername = "*"
    let mainView = UIView()
    let myTextV1 = UITextField()
    let addComment = API()
    var temp = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        api.getCommentNotification(0)
        let blankView = UIView()
        tableView.tableFooterView = blankView
        addComment.delegate = self
        myTextV1.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        mainView.frame = CGRect(x: 0, y: tableView.contentOffset.y + temp - 40, width: view.bounds.width, height: 40)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        mainView.hidden = true
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return CommentNotification.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === addComment {
            let res = data["result"] as! Int
            if res == 1 {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "评论成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "评论失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                })
            }
        }
        else {
            CommentNotification = data["result"] as! [NSDictionary]
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            for item in CommentNotification {
                markRead.readCommentNotification(item["id"] as! Int)
                let avatar = item["avatar"] as! String
                var pics = [String]()
                pics.append(avatar)
                pics.append(item["pic"] as! String)
                for url in pics {
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
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        myTextV1.resignFirstResponder()
        mainView.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeContentViewPoint:", name: UIKeyboardWillShowNotification, object: nil)
        myTextV1.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 60, height: 40)
        myTextV1.borderStyle = UITextBorderStyle.RoundedRect
        myTextV1.backgroundColor = UIColor.whiteColor()
        let fasongBut = UIButton(frame: CGRect(x: view.bounds.width - 60, y: 0, width: 60, height: 40))
        fasongBut.setTitle("确定", forState: UIControlState.Normal)
        fasongBut.backgroundColor = UIColor.orangeColor()
        fasongBut.addTarget(self, action: "pinglunQueding:", forControlEvents: UIControlEvents.TouchUpInside)
        fasongBut.layer.cornerRadius = 5
        fasongBut.layer.masksToBounds = true
        mainView.frame = CGRectMake(0, self.view.bounds.height + tableView.contentOffset.y, self.view.bounds.width, 40)
        mainView.addSubview(myTextV1)
        mainView.addSubview(fasongBut)
        mainView.hidden = false
        view.addSubview(mainView)
        myTextV1.text = ""
        myTextV1.placeholder = "回复" + (CommentNotification[indexPath.section]["nickname"] as! String) + "："
        myTextV1.becomeFirstResponder()
        if CommentNotification[indexPath.section]["type"] as! String == "mission" {
            type = 0
            talkerUsername = CommentNotification[indexPath.section]["username"] as! String
            fasongBut.tag = CommentNotification[indexPath.section]["mid"] as! Int
        }
        else {
            type = 1
            talkerUsername = CommentNotification[indexPath.section]["username"] as! String
            fasongBut.tag = CommentNotification[indexPath.section]["eid"] as! Int
        }

    }
    
    func changeContentViewPoint(notification: NSNotification) {
        let value = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyBoardEndY = value.CGRectValue().origin.y
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        UIView.animateWithDuration(duration.doubleValue, animations: { () -> Void in
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.integerValue)!)
            self.mainView.center = CGPointMake(self.mainView.center.x, self.tableView.contentOffset.y + keyBoardEndY  - self.mainView.bounds.height / 2)
            
            self.temp = keyBoardEndY
        })
    }
    
    func pinglunQueding(button: UIButton) {
        if type == 1 {
            if myTextV1.text != "" {
                addComment.addEvidenceComment(button.tag, content: myTextV1.text, talkerUsername: talkerUsername)
            }
        }
        else {
            if myTextV1.text != "" {
                addComment.addMissionComment(button.tag, content: myTextV1.text, talkerUsername: talkerUsername)
            }
        }
        myTextV1.resignFirstResponder()
        mainView.hidden = true
        mainView.center = CGPointMake(mainView.center.x, view.bounds.height)
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        if api === addComment {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "评论失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
        println(errno)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentNotificationCell", forIndexPath: indexPath) as! UITableViewCell
        let avatar = cell.viewWithTag(1) as! UIImageView
        let missionImage = cell.viewWithTag(2) as! UIImageView
        let nicknameLabel = cell.viewWithTag(3) as! UILabel
        let content = cell.viewWithTag(4) as! UILabel
        let timeLabel = cell.viewWithTag(5) as! UILabel
        avatar.layer.cornerRadius = 5
        avatar.layer.masksToBounds = true
        if PicDic.picDic[CommentNotification[indexPath.section]["avatar"] as! String] == nil {
            avatar.image = UIImage(named: "DefaultAvatar")
        }
        else {
            avatar.image = PicDic.picDic[CommentNotification[indexPath.section]["avatar"] as! String]
        }
        if CommentNotification[indexPath.section]["pic"] as! String == "" {
            missionImage.image = UIImage(named: "noimage1")
        }
        else if PicDic.picDic[CommentNotification[indexPath.section]["pic"] as! String] == nil {
            missionImage.image = UIImage(named: "noimage2")
        }
        else {
            missionImage.image = PicDic.picDic[CommentNotification[indexPath.section]["pic"] as! String]
        }
        nicknameLabel.text = CommentNotification[indexPath.section]["nickname"] as? String
        content.text = CommentNotification[indexPath.section]["content"] as? String
        timeLabel.text = friendlyTime(CommentNotification[indexPath.section]["createTime"] as! String)
        // Configure the cell...

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
