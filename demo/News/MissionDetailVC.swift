//
//  MissionDetailVC.swift
//  demo
//
//  Created by HoJolin on 15/4/16.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MissionDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, APIProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var mid = -1
    var stuct = NSDictionary()
    let getMission = API()
    let getEvidences = API()
    var buffer = 0
    
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    @IBAction func segmentCtrlChange(sender: UISegmentedControl) {
        if segmentCtrl.selectedSegmentIndex == 1 {
            getEvidences.getEvidencesFromMid(mid)
        }
        selfTableView.reloadData()
    }
    @IBOutlet weak var selfTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMission.getMissionFromID(mid)
        getMission.delegate = self
        getEvidences.delegate = self
        selfTableView.dataSource = self
        selfTableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentCtrl.selectedSegmentIndex == 0 {
            return 7
        }
        else {
            return 0
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentCtrl.selectedSegmentIndex == 0 && stuct["pics"] != nil {
            let pics = stuct["pics"] as! [NSDictionary]
            if indexPath.row == 0 {
                return 44
            }
            else if indexPath.row == 1 {
                return self.view.bounds.width - 55
            }
            else if indexPath.row == 2 {
                if pics.count > 1 {
                    return view.bounds.width / 4
                }
                else {
                    return 0
                }
            }
            else if indexPath.row == 3 {
                return 55
            }
            else if indexPath.row == 4 {
                return 44
            }
            else if indexPath.row == 5 {
                if stuct["slogan"] as? String != "*" && stuct["slogan"] as! String != "" {
                    return 44
                }
                else {
                    return 0
                }
            }
            else {
                return 30
            }
            
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentCtrl.selectedSegmentIndex == 0 && stuct["pics"] != nil {
            let pics = stuct["pics"] as! [NSDictionary]
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
                cell.timeLabel.text = stuct["createTime"] as? String
                cell.nameLabel.text = stuct["nickname"] as? String
                let url = stuct["avatar"] as! String
                if PicDic.picDic[url] != nil {
                    cell.avatar.image = PicDic.picDic[url]
                }
                else {
                    cell.avatar.image = UIImage(named: "DefaultAvatar")
                }
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("MainImageCell", forIndexPath: indexPath) as! MainImageCell
                cell.countLabel.text = String(pics.count)
                cell.photosData = pics
                if pics.count > buffer {
                    let url =  pics[buffer]["url"] as! String
                    if PicDic.picDic[url] != nil {
                        cell.mainImageView.image = PicDic.picDic[url]
                    }
                    else {
                        cell.mainImageView.image = UIImage()
                    }
                }
                else {
                    cell.mainImageView.image = UIImage()
                }
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("PickPicCell", forIndexPath: indexPath) as! PickPicCell
                cell.pickCollectionView.tag = indexPath.section
                cell.pickCollectionView.delegate = self
                cell.dataSource = pics
                cell.pickCollectionView.reloadData()
                return cell
            }
            else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("StatusCell", forIndexPath: indexPath) as! StatusCell
                let charge = stuct["charge"] as! Int
                if cell.superviseButton.hidden {
                    cell.superviseButton.hidden = false
                }
                else {
                    cell.superviseButton.hidden = true
                    cell.wtfLabel.text = "已监督"
                    cell.lockImageView.hidden = false
                    cell.evidentState.hidden = true
                }
                cell.backgroundColor = UIColor.orangeColor()
                cell.typeLabel.text = "任务剩余时间"
                cell.meneyLabel.text = String(charge)
                let formatSever = NSDateFormatter()
                formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let endTime = formatSever.dateFromString(stuct["endTime"] as! String)
                let hour = Int(endTime!.timeIntervalSinceNow / 3600)
                if hour < 0 {
                    cell.timeLabel.text = "已完成"
                }
                else {
                    cell.timeLabel.text = "\(hour / 24)天\(hour % 24)小时"
                }
                return cell
            }
            else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! DetailCell
                cell.titleLabel.text = stuct["title"] as? String
                cell.contentLabel.text = stuct["content"] as? String
                return cell
            }
            else if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SloganCell", forIndexPath: indexPath) as! SloganCell
                if stuct["slogan"] as? String != "*" {
                    cell.sloganLabel.text = stuct["slogan"] as? String
                }
                else {
                    cell.sloganLabel.text = ""
                }
                return cell
            }
            else if indexPath.row == 6 {
                let numOfLike = stuct["numOfLike"] as! Int
                let numOfComment = stuct["numOfComment"] as! Int
                let cell = tableView.dequeueReusableCellWithIdentifier("LikeCell", forIndexPath: indexPath) as! LikeCell
                cell.likeLabel.text = String(numOfLike)
                cell.commentLabel.text = String(numOfComment)
                cell.locationLabel.text = stuct["location"] as? String
                return cell
            }
        }
        return UITableViewCell()
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.bounds.width / 4 - 1, height: view.bounds.width / 4 - 1)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let pics = stuct["pics"] as! [NSDictionary]
        let url = pics[indexPath.row]["url"] as! String
        let cell = selfTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: collectionView.tag)) as! MainImageCell
        cell.mainImageView.image = PicDic.picDic[url]
        buffer = indexPath.row
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        println(errno)
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === getMission {
            stuct = data["result"] as! NSDictionary
            let avatar = ["url": stuct["avatar"] as! String]
            var pics = stuct["pics"] as! [NSDictionary]
            pics.append(avatar)
            for pic in pics {
                let url = pic["url"] as! String
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
                                    self.selfTableView.reloadData()
                                })
                            }
                        }
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.selfTableView.reloadData()
            })
        }
        else if api === getEvidences {
            println(data)
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
