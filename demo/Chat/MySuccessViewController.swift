//
//  MySuccessViewController.swift
//  demo
//
//  Created by HoJolin on 15/5/9.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MySuccessViewController: UIViewController, APIProtocol, UITableViewDataSource, UITableViewDelegate ,UICollectionViewDataSource, UIActionSheetDelegate {

    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var noCollection: UICollectionView!
    @IBOutlet weak var yesCollecttion: UICollectionView!
    @IBOutlet weak var viewTable: UITableView!
    var mid = -1
    let api1 = API()
    let api2 = API()
    var res = NSDictionary()
    let formatSever = NSDateFormatter()
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var backgroundView: UIScrollView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var againButton: UIButton!
    @IBAction func againButtonClick(sender: UIButton) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("SelectNewMission") as! UIViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func payButtonClick(sender: UIButton) {
        let actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("打赏30%")
        actionSheet.addButtonWithTitle("打赏60%")
        actionSheet.addButtonWithTitle("打赏100%")
        actionSheet.addButtonWithTitle("取消")
        actionSheet.cancelButtonIndex = 3
        actionSheet.showInView(view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            var percentage = 0
            if buttonIndex == 0 {
                percentage = 30
            }
            else if buttonIndex == 1 {
                percentage = 60
            }
            else if buttonIndex == 2 {
                percentage = 100
            }
            api2.sendMoneyForMission(mid, percentage: percentage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api1.delegate = self
        api2.delegate = self
        api1.getMissionFromIDForStatic(mid)
        navigationItem.title = "任务判定"
        viewTable.dataSource = self
        viewTable.delegate = self
        formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatSever.timeZone = NSTimeZone(forSecondsFromGMT: 8 * 3600)
        backgroundView.contentSize = CGSize(width: 0, height: 672)
        yesCollecttion.dataSource = self
        noCollection.dataSource = self
        againButton.layer.cornerRadius = 3
        againButton.layer.masksToBounds = true
        payButton.layer.cornerRadius = 3
        payButton.layer.masksToBounds = true
        detailButton.hidden = true
        payButton.enabled = false
//        let button = UIButton(frame: CGRect(x: 160, y: 650, width: 50, height: 30))
//        button.backgroundColor = UIColor.greenColor()
//        backgroundView.addSubview(button)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let vote = res["vote"] as! NSDictionary
        var dataSource = [String]()
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PickCollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        let imageView = cell.viewWithTag(1) as! UIImageView
        if collectionView === yesCollecttion {
            dataSource = vote["yesVote"] as! [String]
        }
        else {
            dataSource = vote["noVote"] as! [String]
        }
        let url = dataSource[indexPath.row]
        if PicDic.picDic[url] == nil {
            imageView.image = UIImage(named: "DefaultAvatar")
        }
        else {
            imageView.image = PicDic.picDic[url]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if res["username"] != nil {
            let vote = res["vote"] as! NSDictionary
            if collectionView === yesCollecttion {
                let yesVote = vote["yesVote"] as! [String]
                return yesVote.count
            }
            else {
                let noVote = vote["noVote"] as! [String]
                return noVote.count
            }
        }
        else {
            return 0
        }
    }
    
    func reload() {
        dispatch_async(dispatch_get_main_queue(), {
            self.viewTable.reloadData()
            self.missionLabel.text = self.res["title"] as? String
            self.yesCollecttion.reloadData()
            self.noCollection.reloadData()
            if self.res["ifReward"] as! Int == 1 {
                self.detailButton.hidden = false
                self.payButton.enabled = false
            }
            else {
                self.detailButton.hidden = true
                self.payButton.enabled = true
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
        if api === api2 {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "打赏失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 265
        }
        else {
            return 55
        }
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
                let vote = res["vote"] as! NSDictionary
                let yesVote = vote["yesVote"] as! [String]
                for url in yesVote {
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
                                        self.yesCollecttion.reloadData()
                                    })
                                }
                            }
                        })
                    }
                }
                let noVote = vote["noVote"] as! [String]
                for url in noVote {
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
                                        self.noCollection.reloadData()
                                    })
                                }
                            }
                        })
                    }
                }
            }
        }
        else {
            let res = data["result"] as! Int
            if res == 1 {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "打赏成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    self.api1.getMissionFromIDForStatic(self.mid)
                })
            }
            else if res == -2 {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "金币不足", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "打赏失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                })
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MissionDetailVC") as! MissionDetailVC
        vc.mid = mid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destinationViewController as! RewardTableViewController
        vc.myTitle = res["title"] as! String
        vc.nickname = res["nickname"] as! String
        vc.avatar = res["avatar"] as! String
        vc.reward = res["reward"] as! [NSDictionary]
    }
    

}
