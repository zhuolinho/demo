//
//  MeViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/13.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MeViewController: UITableViewController, APIProtocol {

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var rmbLabel: UILabel!
    let api = API()
    
    @IBAction func shareButtonClick(sender: UIButton) {
        RespImageContent(UIImage())
    }
    @IBAction func inviteButtonClick(sender: UIButton) {
//        let resp = SendMessageToWXReq()
//        resp.text = "https://itunes.apple.com/cn/app/meng-huan-xi-you/id940547441"
//        resp.bText = true
//        resp.scene = 0
//        WXApi.sendReq(resp)
        let message = WXMediaMessage()
        message.title = "千万别下载这游戏"
        message.description = "这种炒冷饭的作品也能登顶？国产手游什么时候才能雄起？"
        message.setThumbImage(UIImage(named: "DefaultAvatar"))
        let ext = WXWebpageObject()
        ext.webpageUrl = "https://itunes.apple.com/cn/app/meng-huan-xi-you/id940547441"
        message.mediaObject = ext
        let rep = SendMessageToWXReq()
        rep.bText = false
        rep.message = message
        rep.scene = 0
        WXApi.sendReq(rep)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        avatarView.layer.cornerRadius = 50
        avatarView.layer.masksToBounds = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        if !API.userInfo.tokenValid {
            api.getMyInfo()
        }
        rmbLabel.text = String(API.userInfo.rmb)
        avatarView.image = API.userInfo.profilePhoto
        signLabel.text = API.userInfo.signature
        nameLabel.text = API.userInfo.nickname
        if API.userInfo.gender == "M" {
            genderLabel.text =  "男"
        }
        else if API.userInfo.gender == "F" {
            genderLabel.text =  "女"
        }
        else {
            genderLabel.text =  "未设置"
        }
        phoneLabel.text = API.userInfo.phone
    }
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return self.tableView.bounds.width * 2 / 3
        }
        else {
            return 150
        }
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! NSDictionary
        if res.count > 0 {
            API.userInfo.username = res["username"] as! String
            API.userInfo.nickname = res["nickname"] as! String
            API.userInfo.phone = res["phone"] as! String
            API.userInfo.gender = res["gender"] as! String
            API.userInfo.profilePhotoUrl = res["avatar"] as! String
            API.userInfo.signature = res["sign"] as! String
            API.userInfo.weixin = res["weixin"] as! String
            API.userInfo.rmb = res["rmb"] as! Int
            if !API.userInfo.profilePhotoUrl.isEmpty {
                let url = NSURL(string: (API.userInfo.imageHost + API.userInfo.profilePhotoUrl))
                let request: NSURLRequest = NSURLRequest(URL: url!)
                let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        let img: UIImage? = UIImage(data: data)
                        let avatar: UIImage? = img
                        if avatar != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                PicDic.picDic[API.userInfo.profilePhotoUrl] = avatar
                                API.userInfo.profilePhoto = avatar!
                                self.rmbLabel.text = String(API.userInfo.rmb)
                                self.avatarView.image = API.userInfo.profilePhoto
                                self.signLabel.text = API.userInfo.signature
                                self.nameLabel.text = API.userInfo.nickname
                                if API.userInfo.gender == "M" {
                                    self.genderLabel.text =  "男"
                                }
                                else if API.userInfo.gender == "F" {
                                    self.genderLabel.text =  "女"
                                }
                                else {
                                    self.genderLabel.text =  "未设置"
                                }
                                self.phoneLabel.text = API.userInfo.phone
                                self.tableView.reloadData()
                            })
                        }
                    }
                })
            }
            EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.username, password: "123456", completion: {
                (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                if (error == nil) {
                    API.userInfo.tokenValid = true
                }
                else {
                    API.userInfo.tokenValid = false
                    EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.phone, password: "123456", completion: {
                        (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                        if (error == nil) {
                            API.userInfo.tokenValid = true
                        }
                        else {
                            EaseMob.sharedInstance().chatManager.registerNewAccount(API.userInfo.username, password: "123456", error: nil)
                        }
                        }, onQueue: nil)
                }
                }, onQueue: nil)
            APService.setTags([API.userInfo.username], alias: API.userInfo.username, callbackSelector: nil, target: self)
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
