//
//  OtherSuccessViewController.swift
//  demo
//
//  Created by HoJolin on 15/5/9.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class OtherSuccessViewController: UIViewController, APIProtocol, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {

    @IBOutlet weak var backgroundView: UIScrollView!
    @IBAction func shareButtonClick(sender: AnyObject) {
        if res["shareUrl"] != nil {
            let actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.addButtonWithTitle("分享给微信好友")
            actionSheet.addButtonWithTitle("分享到朋友圈")
            actionSheet.addButtonWithTitle("取消")
            actionSheet.cancelButtonIndex = 2
            actionSheet.showInView(view)
        }
    }
    @IBOutlet weak var viewTable: UITableView!
    var mid = -1
    let api1 = API()
    var res = NSDictionary()
    let formatSever = NSDateFormatter()
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var againButton: UIButton!
    @IBAction func againButtonClick(sender: UIButton) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("SelectNewMission") as! UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api1.delegate = self
        api1.getMissionFromIDForStatic(mid)
        navigationItem.title = "任务判定"
        viewTable.dataSource = self
        viewTable.delegate = self
        formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatSever.timeZone = NSTimeZone(forSecondsFromGMT: 8 * 3600)
        againButton.layer.cornerRadius = 3
        againButton.layer.masksToBounds = true
        backgroundView.contentSize = CGSize(width: 0, height: 504)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload() {
        dispatch_async(dispatch_get_main_queue(), {
            self.viewTable.reloadData()
            self.detailLabel.text = (self.res["nickname"] as! String) + "在" + (self.res["title"] as! String) + "任务里成功挑战自己，\n有赖于你的严格监督，\n" + (self.res["nickname"] as! String) + "收获了更好的自己!\n赶快开展你的挑战旅程，\n和小伙伴们一起成长吧"
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 265
        }
        else {
            return 55
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell =  tableView.dequeueReusableCellWithIdentifier("ImageViewCell", forIndexPath: indexPath) as! UITableViewCell
            let imageView = cell.viewWithTag(1) as! UIImageView
            let markView = cell.viewWithTag(2) as! UIImageView
            markView.hidden = true
            if res["username"] != nil {
                let pics = res["pics"] as! [NSDictionary]
                if pics.count > 0 {
                    let url = pics[0]["url"] as! String
                    if PicDic.picDic[url] != nil {
                        imageView.image = PicDic.picDic[url]
                    }
                    else {
                        imageView.image = UIImage(named: "noimage2")
                    }
                }
                else {
                    imageView.image = UIImage(named: "noimage1")
                }
                if res["status"] as! Int == 2 {
                    markView.hidden = false
                    markView.image = UIImage(named: "v_03")
                }
                else if res["status"] as! Int == 3 {
                    markView.hidden = false
                    markView.image = UIImage(named: "stamp1")
                }
                else {
                    markView.hidden = true
                }
            }
            else {
                imageView.image = UIImage(named: "noimage2")
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! UITableViewCell
            let timeLabel = cell.viewWithTag(1) as! UILabel
            let chargeLabel = cell.viewWithTag(2) as! UILabel
            if res["username"] == nil {
                timeLabel.text = ""
                chargeLabel.text = ""
            }
            else {
                let endTime = formatSever.dateFromString(res["endTime"] as! String)
                let hour = Int(endTime!.timeIntervalSinceNow / 3600)
                let charge = res["charge"] as! Int
                if res["status"] as! Int != 1 && res["status"] as! Int != 0 {
                    cell.backgroundColor = UIColor.lightGrayColor()
                    timeLabel.text = "已完成"
                }
                else {
                    cell.backgroundColor = UIColor.orangeColor()
                    timeLabel.text = "\(hour / 24)天\(hour % 24)小时"
                }
                chargeLabel.text = String(charge)
            }
            return cell
        }
        
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        println(errno)
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === api1 {
            res = data["result"] as! NSDictionary
            if res["username"] != nil {
                var pics = res["pics"] as! [NSDictionary]
                if pics.count > 0 {
                    let url = pics[0]["url"] as! String
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
                                        self.viewTable.reloadData()
                                    })
                                }
                            }
                        })
                    }
                }
                reload()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MissionDetailVC") as! MissionDetailVC
        vc.mid = mid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            let message = WXMediaMessage()
            message.title = "“从今天起，我要开启一项新挑战！想看我如何完成挑战？来监督我吧！”"
            message.description = "求监督是国内首款集社交、游戏与习惯养成与一身的软件，用好友的力量督促你一直进步，让成长变得更简单。\n在这里，坚持不再是一件孤独的事。"
//            let pics = res["pics"] as! [NSDictionary]
//            if pics.count > 0 {
//                let url = pics[0]["url"] as! String
//                if PicDic.picDic[url] != nil {
//                    message.setThumbImage(PicDic.picDic[url])
//                }
//                else {
//                    message.setThumbImage(UIImage(named: "noimage2"))
//                }
//            }
//            else {
//                message.setThumbImage(UIImage(named: "noimage1"))
//            }
            message.setThumbImage(UIImage(named: "logo"))
            let ext = WXWebpageObject()
            ext.webpageUrl = res["shareUrl"] as! String
            message.mediaObject = ext
            let rep = SendMessageToWXReq()
            rep.bText = false
            rep.message = message
            rep.scene = 0
            WXApi.sendReq(rep)
        }
        else if buttonIndex == 1 {
            let message = WXMediaMessage()
            message.title = "“从今天起，我要开启一项新挑战！想看我如何完成挑战？来监督我吧！”"
            message.setThumbImage(UIImage(named: "logo"))
            let ext = WXWebpageObject()
            ext.webpageUrl = res["shareUrl"] as! String
            message.mediaObject = ext
            let rep = SendMessageToWXReq()
            rep.bText = false
            rep.message = message
            rep.scene = 1
            WXApi.sendReq(rep)
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
