//
//  MissionDetailVC.swift
//  demo
//
//  Created by HoJolin on 15/4/16.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MissionDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, APIProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var mid = -1
    var stuct = NSMutableDictionary()
    var evidences = [NSMutableDictionary]()
    var missionComment = NSMutableDictionary()
    let getMission = API()
    let getEvidences = API()
    let getCommentsAndLikes = API()
    var buffer = 0
    var segmentCtrl = UISegmentedControl()
    var temp = [Int]()
    let setLike = API()
    
    @IBOutlet weak var selfTableView: UITableView!
    
    func segmentCtrlChange() {
        if segmentCtrl.selectedSegmentIndex == 1 {
            getEvidences.getEvidencesFromMid(mid)
        }
        else if segmentCtrl.selectedSegmentIndex == 0 {
            getMission.getMissionFromID(mid)
        }
        else {
            getCommentsAndLikes.getMissionCommentsAndMissionLikes(mid)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.selfTableView.reloadData()
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(mid)
        segmentCtrl.layer.cornerRadius = 8
        segmentCtrl.layer.masksToBounds = true
        segmentCtrl = UISegmentedControl(items: ["任务", " 证据", "评论"])
        segmentCtrl.frame = CGRect(x: 0, y: 64, width: view.bounds.width, height: 35)
        segmentCtrl.tintColor = UIColor.orangeColor()
        segmentCtrl.backgroundColor = UIColor.whiteColor()
        segmentCtrl.addTarget(self, action: "segmentCtrlChange", forControlEvents: UIControlEvents.ValueChanged)
        segmentCtrl.selectedSegmentIndex = 0
        segmentCtrlChange()
        view.addSubview(segmentCtrl)
        getMission.delegate = self
        getEvidences.delegate = self
        getCommentsAndLikes.delegate = self
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
        else if segmentCtrl.selectedSegmentIndex == 1 {
            let comments = evidences[section]["comment"] as! [NSDictionary]
            return 7 + comments.count
        }
        else {
            if section == 0 {
                return 2
            }
            else {
                if missionComment["comment"] != nil {
                    let comments = missionComment["comment"] as! [NSDictionary]
                    return comments.count
                }
                else {
                    return 0
                }
            }
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
        if segmentCtrl.selectedSegmentIndex == 1 {
            let pics = evidences[indexPath.section]["pics"] as! [NSDictionary]
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
                if evidences[indexPath.section]["slogan"] as? String != "*" && evidences[indexPath.section]["slogan"] as! String != "" {
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
        else {
            if indexPath.section == 0 && indexPath.row == 0 {
                return 30
            }
            else if indexPath.section == 0 && indexPath.row == 1 {
                if missionComment["like"] != nil {
                    let like = missionComment["like"] as! [NSDictionary]
                    if like.count > 0 {
                        return 50
                    }
                }
                return 0
            }
            return 100
        }
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
                cell.countLabel.hidden = true
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
                cell.pickCollectionView.tag = -1
                cell.pickCollectionView.delegate = self
                cell.dataSource = pics
                dispatch_async(dispatch_get_main_queue(), {
                    cell.pickCollectionView.reloadData()
                })
                return cell
            }
            else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("StatusCell", forIndexPath: indexPath) as! StatusCell
                cell.superviseButton.addTarget(self, action: "viceButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                let charge = stuct["charge"] as! Int
                if stuct["myStatus"] as! Int == 0  {
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
                if stuct["ifLike"] as! Int == 1 {
                    cell.likeButton.setImage(UIImage(named: "task_5"), forState: UIControlState.Normal)
                }
                else {
                    cell.likeButton.setImage(UIImage(named: "task_6"), forState: UIControlState.Normal)
                }
                cell.likeButton.tag = indexPath.section
                cell.likeButton.addTarget(self, action: "likeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
        }
        else if segmentCtrl.selectedSegmentIndex == 1 {
            let evident = evidences[indexPath.section]
            let pics = evident["pics"] as! [NSDictionary]
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
                cell.timeLabel.text = evident["createTime"] as? String
                cell.nameLabel.text = evident["nickname"] as? String
                let url = evident["avatar"] as! String
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
                if pics.count > temp[indexPath.section] {
                    let url =  pics[temp[indexPath.section]]["url"] as! String
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
                dispatch_async(dispatch_get_main_queue(), {
                    cell.pickCollectionView.reloadData()
                })
                return cell
            }
            else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("StatusCell", forIndexPath: indexPath) as! StatusCell
                let charge = evident["charge"] as! Int
                cell.superviseButton.hidden = true
                cell.lockImageView.hidden = true
                cell.evidentState.hidden = false
                cell.wtfLabel.text = "任务状态"
                cell.backgroundColor = UIColor.blackColor()
                cell.typeLabel.text = "证据拍摄时间"
                cell.meneyLabel.text = String(charge)
                let formatSever = NSDateFormatter()
                formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let formatCell = NSDateFormatter()
                formatCell.dateFormat = "MM:dd HH:mm"
                cell.timeLabel.text = formatCell.stringFromDate(formatSever.dateFromString(stuct["createTime"] as! String)!)
                return cell
            }
            else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! DetailCell
                cell.titleLabel.text = evident["title"] as? String
                cell.contentLabel.text = evident["content"] as? String
                return cell
            }
            else if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SloganCell", forIndexPath: indexPath) as! SloganCell
                if evident["slogan"] as? String != "*" {
                    cell.sloganLabel.text = evident["slogan"] as? String
                }
                else {
                    cell.sloganLabel.text = ""
                }
                return cell
            }
            else if indexPath.row == 6 {
                let numOfLike = evident["numOfLike"] as! Int
                let numOfComment = evident["numOfComment"] as! Int
                let cell = tableView.dequeueReusableCellWithIdentifier("LikeCell", forIndexPath: indexPath) as! LikeCell
                cell.likeLabel.text = String(numOfLike)
                cell.commentLabel.text = String(numOfComment)
                cell.locationLabel.text = evident["location"] as? String
                if evident["ifLike"] as! Int == 1 {
                    cell.likeButton.setImage(UIImage(named: "task_5"), forState: UIControlState.Normal)
                }
                else {
                    cell.likeButton.setImage(UIImage(named: "task_6"), forState: UIControlState.Normal)
                }
                cell.likeButton.tag = indexPath.section
                cell.likeButton.addTarget(self, action: "likeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
            else if indexPath.row > 6 {
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
                let comments = evidences[indexPath.section]["comment"] as! [NSDictionary]
                let comment = comments[indexPath.row - 7]
                let nickname = comment["nickname"] as! String
                let content = comment["content"] as! String
                cell.commentLabel.text = nickname + "：" + content
                return cell
            }
        }
        else if segmentCtrl.selectedSegmentIndex == 2 && missionComment["location"] != nil {
            if indexPath.section == 1 {
                let comments = missionComment["comment"] as! [NSDictionary]
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentsCell", forIndexPath: indexPath) as! UITableViewCell
                let avatarView = cell.viewWithTag(1) as! UIImageView
                let nameLable = cell.viewWithTag(2) as! UILabel
                let timeLabel = cell.viewWithTag(3) as! UILabel
                let contentLabel = cell.viewWithTag(4) as! UILabel
                let url = comments[indexPath.row]["avatar"] as! String
                if PicDic.picDic[url] == nil {
                    avatarView.image = UIImage()
                }
                else {
                    avatarView.image = PicDic.picDic[url]
                }
                nameLable.text = comments[indexPath.row]["nickname"] as? String
                timeLabel.text = comments[indexPath.row]["createTime"] as? String
                contentLabel.text = comments[indexPath.row]["content"] as? String
                avatarView.layer.cornerRadius = 25
                avatarView.layer.masksToBounds = true
                return cell
            }
            else {
                if indexPath.row == 0 {
                    let numOfLike = missionComment["numOfLike"] as! Int
                    let numOfComment = missionComment["numOfComment"] as! Int
                    let cell = tableView.dequeueReusableCellWithIdentifier("LikeCell", forIndexPath: indexPath) as! LikeCell
                    cell.likeLabel.text = String(numOfLike)
                    cell.commentLabel.text = String(numOfComment)
                    cell.locationLabel.text = missionComment["location"] as? String
                    if missionComment["ifLike"] as! Int == 1 {
                        cell.likeButton.setImage(UIImage(named: "task_5"), forState: UIControlState.Normal)
                    }
                    else {
                        cell.likeButton.setImage(UIImage(named: "task_6"), forState: UIControlState.Normal)
                    }
                    cell.likeButton.tag = indexPath.section
                    cell.likeButton.addTarget(self, action: "likeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("AvatarsCell", forIndexPath: indexPath) as! UITableViewCell
                    let avatarCollect = cell.viewWithTag(2) as! UICollectionView
                    avatarCollect.dataSource = self
                    dispatch_async(dispatch_get_main_queue(), {
                        avatarCollect.reloadData()
                    })
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PickCollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        let imageView = cell.viewWithTag(1) as! UIImageView
        let dataSource = missionComment["like"] as! [NSDictionary]
        let url = dataSource[indexPath.row]["avatar"] as! String
        if PicDic.picDic[url] == nil {
            imageView.image = UIImage()
        }
        else {
            imageView.image = PicDic.picDic[url]
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let like = missionComment["like"] as! [NSDictionary]
        return like.count
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.bounds.width / 4 - 1, height: view.bounds.width / 4 - 1)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.tag == -1{
            let pics = stuct["pics"] as! [NSDictionary]
            let url = pics[indexPath.row]["url"] as! String
            let cell = selfTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! MainImageCell
            cell.mainImageView.image = PicDic.picDic[url]
            buffer = indexPath.row
        }
        else {
            let pics = evidences[collectionView.tag]["pics"] as! [NSDictionary]
            let url = pics[indexPath.row]["url"] as! String
            let cell = selfTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: collectionView.tag)) as! MainImageCell
            cell.mainImageView.image = PicDic.picDic[url]
            temp[collectionView.tag] = indexPath.row
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if segmentCtrl.selectedSegmentIndex == 0 {
            return 1
        }
        else if segmentCtrl.selectedSegmentIndex == 1 {
            return evidences.count
        }
        else {
            return 2
        }
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        println(errno)
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === getMission {
            stuct = data["result"] as! NSMutableDictionary
            if stuct["avatar"] != nil {
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
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.selfTableView.reloadData()
            })
        }
        else if api === getEvidences {
            evidences = data["result"] as! [NSMutableDictionary]
            for item in evidences {
                let avatar = ["url": item["avatar"] as! String]
                var pics = item["pics"] as! [NSDictionary]
                pics.append(avatar)
                temp.append(0)
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
        }
        else if api === getCommentsAndLikes {
            missionComment = data["result"] as! NSMutableDictionary
            if missionComment["like"] != nil {
                var likesAndComments = missionComment["like"] as! [NSDictionary]
                let comments = missionComment["comment"] as! [NSDictionary]
                likesAndComments += comments
                for item in likesAndComments {
                    let url = item["avatar"] as! String
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
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.selfTableView.reloadData()
            })
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func likeButtonClick(button: UIButton) {
        if segmentCtrl.selectedSegmentIndex == 1 {
            var stu = evidences[button.tag]
            let ifLike = stu["ifLike"] as! Int
            setLike.setEvidenceLike(mid, ifLike: 1 - ifLike)
            if ifLike == 0 {
                stu["ifLike"] = 1
                stu["numOfLike"] = stu["numOfLike"] as! Int + 1
            }
            else {
                stu["ifLike"] = 0
                stu["numOfLike"] = stu["numOfLike"] as! Int - 1
            }
        }
        else if segmentCtrl.selectedSegmentIndex == 0 {
            let ifLike = stuct["ifLike"] as! Int
            setLike.setMissionLike(stuct["id"] as! Int, ifLike: 1 - ifLike)
            if ifLike == 0 {
                stuct["ifLike"] = 1
                stuct["numOfLike"] = stuct["numOfLike"] as! Int + 1
            }
            else {
                stuct["ifLike"] = 0
                stuct["numOfLike"] = stuct["numOfLike"] as! Int - 1
            }
        }
        else {
            let ifLike = missionComment["ifLike"] as! Int
            setLike.setMissionLike(mid, ifLike: 1 - ifLike)
            if ifLike == 0 {
                missionComment["ifLike"] = 1
                missionComment["numOfLike"] = missionComment["numOfLike"] as! Int + 1
            }
            else {
                missionComment["ifLike"] = 0
                missionComment["numOfLike"] = missionComment["numOfLike"] as! Int - 1
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.selfTableView.reloadData()
        })
    }
    func viceButtonClick(button: UIButton) {
        setLike.setSupervisor(mid)
        stuct["myStatus"] = 1
        dispatch_async(dispatch_get_main_queue(), {
            self.selfTableView.reloadData()
        })
    }
//        if segmentCtrl.selectedSegmentIndex == 1 && indexPath.row > 6  {
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeContentViewPoint", name: UIKeyboardWillShowNotification, object: nil)
//            let myTextV1 = UITextView(frame: CGRect(x: 0, y: 0, width: 280, height: 40))
//            myTextV1.layer.cornerRadius = 5
//            myTextV1.layer.masksToBounds = true
//            let fasongBut = UIButton(frame: CGRect(x: 280, y: 0, width: 40, height: 40))
//            fasongBut.setTitle("确定", forState: UIControlState.Normal)
//            fasongBut.backgroundColor = UIColor.orangeColor()
//            fasongBut.addTarget(self, action: "pinglunQueding", forControlEvents: UIControlEvents.TouchUpInside)
//            let mainView = UIView(frame: CGRectMake(0, 400, 320, 40))
//            view.addSubview(mainView)
//            mainView.addSubview(myTextV1)
//            mainView.addSubview(fasongBut)
//            myTextV1.becomeFirstResponder()
//        }
//    }
//    func changeContentViewPoint() {
//        
//        
//    }
//    func pinglunQueding() {
//        
//    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ViewPhotosSegue" {
            let photosVC = segue.destinationViewController as! PhotosView
            let cell = sender as! MainImageCell
            photosVC.photosData = cell.photosData
            if segmentCtrl.selectedSegmentIndex == 0 {
                photosVC.startIndex = buffer
            }
            else {
                photosVC.startIndex = temp[selfTableView.indexPathForCell(cell)!.section]
            }
        }
    }
    

}
