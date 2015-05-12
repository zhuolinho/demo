//
//  MyVoteViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/29.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MyVoteViewController: UIViewController, APIProtocol, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var viewTable: UITableView!
    @IBOutlet weak var evidenceLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var mid = -1
    let api = API()
    var res = NSDictionary()
    let formatSever = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        api.getMissionFromID(mid)
        navigationItem.title = "任务总结"
        viewTable.dataSource = self
        viewTable.delegate = self
        formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatSever.timeZone = NSTimeZone(forSecondsFromGMT: 8 * 3600)
        backLabel.layer.cornerRadius = 5
        backLabel.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        println(errno)
    }
    
    func reload() {
        dispatch_async(dispatch_get_main_queue(), {
            let endTime = self.formatSever.dateFromString(self.res["endTime"] as! String)
            let hour = Int((endTime!.timeIntervalSinceNow + 24 * 3600) / 3600)
            self.timeLabel.text = "距离投票截止还有\(hour)小时"
            self.viewTable.reloadData()
            self.commentLabel.text = String(self.res["totalNumOfComment"] as! Int)
            self.likeLabel.text = String(self.res["totalNumOfLike"] as! Int)
            self.evidenceLabel.text = String(self.res["numOfEvidence"] as! Int)
            let frontLabel = UILabel(frame: CGRect(x: Int(self.view.bounds.width / 2 - 150), y: 526, width: (24 - hour) * 300 / 24, height: 21))
            frontLabel.layer.cornerRadius = 5
            frontLabel.layer.masksToBounds = true
            frontLabel.backgroundColor = UIColor.orangeColor()
            self.view.addSubview(frontLabel)
            
        })
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        res = data["result"] as! NSDictionary
        if res["achievement"] != nil {
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
            if res["achievement"] != nil {
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
                    markView.image = UIImage(named: "mission12_03")
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
            if res["achievement"] == nil {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MissionDetailVC") as! MissionDetailVC
        vc.mid = mid
        navigationController?.pushViewController(vc, animated: true)
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
