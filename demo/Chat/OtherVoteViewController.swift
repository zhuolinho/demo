//
//  MyVoteViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/29.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class OtherVoteViewController: UIViewController, APIProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var viewTable: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var evidentLabel: UILabel!
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBAction func yesButtonClick(sender: UIButton) {
        yesButton.enabled = false
        noButton.enabled = false
        api2.addVoteForMission(mid, decision: 1)
    }
    @IBAction func noButtonClicl(sender: AnyObject) {
        yesButton.enabled = false
        noButton.enabled = false
        api2.addVoteForMission(mid, decision: 0)
    }
    
    var mid = -1
    let api1 = API()
    let api2 = API()
    var res = NSDictionary()
    let formatSever = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.enabled = false
        noButton.enabled = false
        api1.delegate = self
        api2.delegate = self
        api1.getMissionFromID(mid)
        navigationItem.title = "任务总结"
        viewTable.dataSource = self
        viewTable.delegate = self
        formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
        yesButton.layer.cornerRadius = 3
        noButton.layer.cornerRadius = 3
        yesButton.layer.masksToBounds = true
        noButton.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        if api === api2 {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "提交失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                self.yesButton.enabled = true
                self.noButton.enabled = true
            })
        }
    }
    
    func reload() {
        dispatch_async(dispatch_get_main_queue(), {
            self.viewTable.reloadData()
            self.nameLabel.text = "你监督" + (self.res["nickname"] as! String) + "发布的任务已完成！"
            self.percentLabel.text = String(self.res["achievement"] as! Int) + "%"
            self.evidentLabel.text = String(self.res["numOfEvidence"] as! Int)
            self.missionLabel.text = (self.res["nickname"] as! String) + "已经很努力了，你会让他通过吗？"
            if self.res["ifVote"] as! Int == 0 {
                self.yesButton.enabled = true
                self.noButton.enabled = true
            }
        })
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === api1 {
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
        else {
            let re = data["result"] as! Int
            if re == 1 {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "提交成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "提交失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    self.yesButton.enabled = true
                    self.noButton.enabled = true
                })
            }
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
                        imageView.image = UIImage()
                    }
                }
                else {
                    imageView.image = UIImage()
                }
                if res["status"] as! Int == 2 {
                    markView.hidden = false
                    markView.image = UIImage(named: "mission1_13")
                }
                else if res["status"] as! Int == 3 {
                    markView.hidden = false
                    markView.image = UIImage(named: "mission1_14")
                }
                else {
                    markView.hidden = true
                }
            }
            else {
                imageView.image = UIImage()
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
                if hour <= 0 {
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
