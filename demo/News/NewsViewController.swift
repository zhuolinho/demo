//
//  NewsViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/12.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController, APIProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UITextFieldDelegate, UIActionSheetDelegate {
    
    var viewa = UIView()
    var ifMyFriend = 1
    var temp = CGFloat(0)
    @IBOutlet weak var titleButton: UIButton!
    @IBAction func filterClick(sender: UIBarButtonItem) {
        mainView.hidden = true
        myTextV1.resignFirstResponder()
        if viewa.hidden {
            viewa.hidden = false
        }
        else {
            viewa.hidden = true
        }
    }
    var requesMore = API()
    var news = [NSMutableDictionary]()
    var skip = -1
    var buffer = [Int]()
    var isRequesing = false
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var myActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let setLike = API()
    let mainView = UIView()
    let myTextV1 = UITextField()
    let addComment = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTextV1.delegate = self
        viewa = UIView(frame: CGRect(x: view.bounds.width - 105, y: 64, width: 92, height: 86))
        view.addSubview(viewa)
        viewa.addSubview(UIImageView(image: UIImage(named: "moment1_07")))
        let button1 = UIButton(frame: CGRect(x: 10, y: 17, width: 73, height: 25))
        button1.titleLabel?.textColor = UIColor.whiteColor()
        button1.setTitle("好友动态", forState: UIControlState.Normal)
        viewa.addSubview(button1)
        button1.addTarget(self, action: "button1Click", forControlEvents: UIControlEvents.TouchUpInside)
        let button2 = UIButton(frame: CGRect(x: 10, y: 55, width: 73, height: 25))
        button2.titleLabel?.textColor = UIColor.whiteColor()
        button2.setTitle("我在监督", forState: UIControlState.Normal)
        button2.addTarget(self, action: "button2Click", forControlEvents: UIControlEvents.TouchUpInside)
        viewa.addSubview(button2)
        requesMore.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshing", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新")
        titleButton.addTarget(self, action: "refreshing", forControlEvents: UIControlEvents.TouchDownRepeat)
        activity.hidesWhenStopped = true
        self.tableView.tableFooterView = activity
        addComment.delegate = self
        myActivity.frame.origin = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 - 32)
        view.addSubview(myActivity)
        myActivity.hidesWhenStopped = true
        refreshing()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if !API.userInfo.tokenValid && API.userInfo.token == "" {
            let mainStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let auth = mainStoryboard.instantiateInitialViewController() as! UIViewController
            self.presentViewController(auth, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewa.hidden = true
        myTextV1.resignFirstResponder()
        mainView.hidden = true
        if ifMyFriend == 0 {
            ifMyFriend = 1
            refreshing()
        }
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        viewa.frame = CGRect(x: view.bounds.width - 105, y: tableView.contentOffset.y + 64, width: 92, height: 86)
        mainView.frame = CGRect(x: 0, y: tableView.contentOffset.y + temp - 40, width: view.bounds.width, height: 40)
        myActivity.frame.origin = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 - 32 + tableView.contentOffset.y)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return news.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 7
//        var add = 0
//        if section < news.count {
//            let stuct = news[section]["struct"] as! NSDictionary
//            let comment = stuct["comment"] as! [NSDictionary]
//            if comment.count > 5 {
//                add = 6
//            }
//            else {
//                add = comment.count
//            }
//        }
//        return 7 + add
    }
//
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section < news.count
        {
            let stuct = news[indexPath.section]["struct"] as! NSDictionary
            let pics = stuct["pics"] as! [NSDictionary]
            if indexPath.row == 0 {
                return 44
            }
            else if indexPath.row == 1 {
                return self.view.bounds.width - 55
            }
            else if indexPath.row == 2 {
                return 0
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section < news.count {
            let type = news[indexPath.section]["type"] as! String
            let stuct = news[indexPath.section]["struct"] as! NSDictionary
            let pics = stuct["pics"] as! [NSDictionary]
            let comments = stuct["comment"] as! [NSDictionary]
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! TitleCell
                cell.timeLabel.text = friendlyTime(stuct["createTime"] as! String)
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
                if pics.count > 0 {
                    cell.countLabel.text = String(pics.count)
                    cell.countLabel.hidden = false
                }
                else {
                    cell.countLabel.hidden = true
                }
                cell.countLabel.layer.cornerRadius = 3
                cell.countLabel.layer.masksToBounds = true
                cell.photosData = pics
                if pics.count > buffer[indexPath.section] {
//                    cell.userInteractionEnabled = true
                    let url =  pics[buffer[indexPath.section]]["url"] as! String
                    if PicDic.picDic[url] != nil {
                        cell.mainImageView.image = PicDic.picDic[url]
                    }
                    else {
                        cell.mainImageView.image = UIImage(named: "noimage2")
                    }
                }
                else {
//                    cell.userInteractionEnabled = false
                    cell.mainImageView.image = UIImage(named: "noimage1")
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
                cell.superviseButton.tag = indexPath.section
                cell.superviseButton.addTarget(self, action: "viceButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                let charge = stuct["charge"] as! Int
                if type == "mission" {
                    if stuct["myStatus"] as! Int == 0 {
                        cell.superviseButton.hidden = false
                    }
                    else {
                        cell.superviseButton.hidden = true
                        cell.wtfLabel.text = "监督中"
                        cell.lockImageView.hidden = false
                        cell.evidentState.hidden = true
                    }
                    cell.backgroundColor = UIColor.orangeColor()
                    cell.meneyLabel.text = String(charge)
                    let formatSever = NSDateFormatter()
                    formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatSever.timeZone = NSTimeZone(forSecondsFromGMT: 8 * 3600)
                    let endTime = formatSever.dateFromString(stuct["endTime"] as! String)
                    let hour = Int(endTime!.timeIntervalSinceNow / 3600)
                    if stuct["status"] as! Int == -1 || stuct["status"] as! Int == 2 {
                        cell.timeLabel.text = "已完成"
                        cell.typeLabel.text = "任务已经过期"
                    }
                    else if stuct["status"] as! Int == 3 {
                        cell.timeLabel.text = "未成功"
                        cell.typeLabel.text = "任务已经过期"
                    }
                    else {
                        cell.timeLabel.text = "\(hour / 24)天\(hour % 24)小时"
                        cell.typeLabel.text = "距离任务结束"
                    }
                }
                else {
                    cell.superviseButton.hidden = true
                    cell.lockImageView.hidden = true
                    cell.evidentState.hidden = false
                    if stuct["status"] as! Int == -1 || stuct["status"] as! Int == 2  {
                        cell.evidentState.text = "已完成"
                    }
                    else if stuct["status"] as! Int == 3 {
                        cell.evidentState.text = "未成功"
                    }
                    else {
                        cell.evidentState.text = "进行中"
                    }
                    cell.wtfLabel.text = "任务状态"
                    cell.backgroundColor = UIColor.blackColor()
                    cell.typeLabel.text = "证据拍摄时间"
                    cell.meneyLabel.text = String(charge)
                    let formatSever = NSDateFormatter()
                    formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatSever.timeZone = NSTimeZone(forSecondsFromGMT: 8 * 3600)
                    let formatCell = NSDateFormatter()
                    formatCell.dateFormat = "MM-dd HH:mm"
                    cell.timeLabel.text = formatCell.stringFromDate(formatSever.dateFromString(stuct["createTime"] as! String)!)
                }
                return cell
            }
            else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! DetailCell
                cell.titleLabel.text = stuct["title"] as? String
                cell.contentLabel.text = stuct["content"] as? String
                return cell
            }
            else if indexPath.row == 6 {
                let numOfLike = stuct["numOfLike"] as! Int
                let numOfComment = stuct["numOfComment"] as! Int
                let cell = tableView.dequeueReusableCellWithIdentifier("LikeCell", forIndexPath: indexPath) as! LikeCell
                cell.likeLabel.text = String(numOfLike)
                cell.commentLabel.text = String(numOfComment)
                cell.locationLabel.text = stuct["location"] as? String
                cell.commentButton.tag = indexPath.section
                cell.commentButton.addTarget(self, action: "commentButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                if stuct["ifLike"] as! Int == 1 {
                    cell.likeButton.setImage(UIImage(named: "task_5"), forState: UIControlState.Normal)
                }
                else {
                    cell.likeButton.setImage(UIImage(named: "task_6"), forState: UIControlState.Normal)
                }
                cell.likeButton.tag = indexPath.section
                cell.likeButton.addTarget(self, action: "likeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.shareButton.tag = indexPath.section
                cell.shareButton.addTarget(self, action: "shareButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
//            else if indexPath.row > 6 && indexPath.row < 12 {
//                let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
//                let comment = comments[indexPath.row - 7]
//                let nickname = comment["nickname"] as! String
//                let content = comment["content"] as! String
//                cell.commentLabel.text = nickname + "：" + content
//                return cell
//            }
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
//            else if indexPath.row == 12 {
//                let cell = tableView.dequeueReusableCellWithIdentifier("MoreCommentsCell", forIndexPath: indexPath) as! MoreCommentsCell
//                return cell
//            }

        }
        return UITableViewCell()
        
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == news.count - 1 && skip != -1 {
            if !isRequesing {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activity.startAnimating()
                })
                requesMore.getMissionsAndEvidences(skip, ifMyFriend: ifMyFriend)
                isRequesing = true
            }
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.bounds.width / 4 - 1, height: view.bounds.width / 4 - 1)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewa.hidden = true
        let stuct = news[collectionView.tag]["struct"] as! NSDictionary
        let pics = stuct["pics"] as! [NSDictionary]
        let url = pics[indexPath.row]["url"] as! String
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: collectionView.tag)) as! MainImageCell
        cell.mainImageView.image = PicDic.picDic[url]
        buffer[collectionView.tag] = indexPath.row
    }
    
    func refreshing() {
        if !isRequesing {
            if refreshControl?.refreshing == false {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.setContentOffset(CGPointMake(0, -60), animated: false)
                    self.myActivity.startAnimating()
                })
            }
            requesMore.getMissionsAndEvidences(0, ifMyFriend: ifMyFriend)
            skip = 0
            isRequesing = true
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 6 {
            viewa.hidden = true
            myTextV1.resignFirstResponder()
            mainView.hidden = true
            let vc = storyboard?.instantiateViewControllerWithIdentifier("MissionDetailVC") as! MissionDetailVC
            let sturt = news[indexPath.section]["struct"] as! NSDictionary
            if news[indexPath.section]["type"] as! String == "mission" && indexPath.row != 6 {
                vc.mid = sturt["id"] as! Int
                vc.initNum = 0
            }
            else if news[indexPath.section]["type"] as! String == "mission" && indexPath.row == 6 {
                vc.mid = sturt["id"] as! Int
                vc.initNum = 2
            }
            else {
                vc.initNum = 1
                vc.mid = sturt["mid"] as! Int
            }
            if indexPath.row != 1 {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func likeButtonClick(button: UIButton) {
        let section = button.tag
        var stuct = news[section]["struct"] as! NSMutableDictionary
        let ifLike = stuct["ifLike"] as! Int
        let id = stuct["id"] as! Int
        if news[section]["type"] as! String == "mission" {
            setLike.setMissionLike(id, ifLike: 1 - ifLike)
        }
        else {
            setLike.setEvidenceLike(id, ifLike: 1 - ifLike)
        }
        if ifLike == 0 {
            stuct["ifLike"] = 1
            stuct["numOfLike"] = stuct["numOfLike"] as! Int + 1
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        else {
            stuct["ifLike"] = 0
            stuct["numOfLike"] = stuct["numOfLike"] as! Int - 1
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    func viceButtonClick(button: UIButton) {
        var stuct = news[button.tag]["struct"] as! NSMutableDictionary
        if stuct["status"] as! Int == 0 || stuct["status"] as! Int == 1 {
            let id = stuct["id"] as! Int
            setLike.setSupervisor(id)
            stuct["myStatus"] = 1
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        else {
            let alert = UIAlertView(title: "任务已结束", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        skip = -1
        isRequesing = false
        dispatch_async(dispatch_get_main_queue(), {
            if self.refreshControl?.refreshing == true {
                self.refreshControl?.endRefreshing()
            }
            if self.activity.isAnimating() {
                self.activity.stopAnimating()
            }
        })
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === requesMore {
            isRequesing = false
            dispatch_async(dispatch_get_main_queue(), {
                if API.userInfo.nickname != "" {
                    self.titleButton.setTitle(API.userInfo.nickname, forState: UIControlState.Normal)
                }
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                if self.activity.isAnimating() {
                    self.activity.stopAnimating()
                }
                if self.myActivity.isAnimating() {
                    self.myActivity.stopAnimating()
                }
            })
            if skip == 0 {
                buffer.removeAll(keepCapacity: true)
                news.removeAll(keepCapacity: true)
            }
            var res = data["result"] as! NSArray
            if res.count > 0 {
                var items = [NSMutableDictionary]()
                for it in res {
                    items.append(it as! NSMutableDictionary)
                    buffer.append(0)
                    let stuct = it["struct"] as! NSDictionary
                    let avatar = ["url": stuct["avatar"] as! String]
                    let pics = stuct["pics"] as! [NSDictionary]
                    var pices = [NSDictionary]()
                    if pics.count > 0 {
                        pices.append(pics[0])
                    }
                    pices.append(avatar)
                    for pic in pices {
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
                                            self.tableView.reloadData()
                                        })
                                    }
                                }
                            })
                        }
                    }
                }
                news += items
                var range = NSMakeRange(self.skip, items.count)
                var indexSet = NSIndexSet(indexesInRange: range)
                self.skip += items.count
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            else {
                skip = -1
            }
        }
    }
    func button1Click() {
        ifMyFriend = 1
        refreshing()
        viewa.hidden = true
    }
    func button2Click() {
        ifMyFriend = 0
        refreshing()
        viewa.hidden = true
    }
    func commentButtonClick(button: UIButton) {
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
        myTextV1.placeholder = "评论..."
        myTextV1.becomeFirstResponder()
//        if news[button.tag]["type"] as! String == "mission" {
        fasongBut.tag = button.tag
//        }
//        else {
//            fasongBut.tag = -((news[button.tag]["struct"] as! NSDictionary)["id"] as! Int)
//        }
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
        var stuct = news[button.tag]["struct"] as! NSMutableDictionary
        let id = stuct["id"] as! Int
        if news[button.tag]["type"] as! String == "mission" {
            if myTextV1.text != "" {
                addComment.addMissionComment(id, content: myTextV1.text, talkerUsername: "*")
            }
        }
        else {
            if myTextV1.text != "" {
                addComment.addEvidenceComment(id, content: myTextV1.text, talkerUsername: "*")
            }
        }
        myTextV1.resignFirstResponder()
        mainView.hidden = true
        mainView.center = CGPointMake(mainView.center.x, view.bounds.height)
        stuct["numOfComment"] = stuct["numOfComment"] as! Int + 1
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func shareButtonClick(button: UIButton) {
        let actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("分享给微信好友")
        actionSheet.addButtonWithTitle("分享到朋友圈")
        actionSheet.addButtonWithTitle("取消")
        actionSheet.cancelButtonIndex = 2
        actionSheet.tag = button.tag
        actionSheet.showInView(view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let stuct = news[actionSheet.tag]["struct"] as! NSDictionary
        if news[actionSheet.tag]["type"] as! String == "mission" {
            if buttonIndex == 0 {
                let message = WXMediaMessage()
                message.title = "“从今天起，我要开启一项新挑战！想看我如何完成挑战？来监督我吧！”"
                message.description = "求监督是国内首款集社交、游戏与习惯养成与一身的软件，用好友的力量督促你一直进步，让成长变得更简单。\n在这里，坚持不再是一件孤独的事。"
                message.setThumbImage(UIImage(named: "logo"))
                let ext = WXWebpageObject()
                ext.webpageUrl = stuct["shareUrl"] as! String
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
                ext.webpageUrl = stuct["shareUrl"] as! String
                message.mediaObject = ext
                let rep = SendMessageToWXReq()
                rep.bText = false
                rep.message = message
                rep.scene = 1
                WXApi.sendReq(rep)
            }
        }
        else {
            if buttonIndex == 0 {
                let message = WXMediaMessage()
                message.title = "我在【求监督】晒了一条新证据，感觉离成为成功人士越来越近了。快来围观我的奋斗历程吧！"
                message.description = "求监督是国内首款集社交、游戏与习惯养成与一身的软件，用好友的力量督促你一直进步，让成长变得更简单。\n在这里，坚持不再是一件孤独的事。"
                message.setThumbImage(UIImage(named: "logo"))
                let ext = WXWebpageObject()
                ext.webpageUrl = stuct["shareUrl"] as! String
                message.mediaObject = ext
                let rep = SendMessageToWXReq()
                rep.bText = false
                rep.message = message
                rep.scene = 0
                WXApi.sendReq(rep)
            }
            else if buttonIndex == 1 {
                let message = WXMediaMessage()
                message.title = "我在【求监督】晒了一条新证据，感觉离成为成功人士越来越近了。快来围观我的奋斗历程吧！"
                message.setThumbImage(UIImage(named: "logo"))
                let ext = WXWebpageObject()
                ext.webpageUrl = stuct["shareUrl"] as! String
                message.mediaObject = ext
                let rep = SendMessageToWXReq()
                rep.bText = false
                rep.message = message
                rep.scene = 1
                WXApi.sendReq(rep)
            }
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "ViewPhotosSegue" {
            let photosVC = segue.destinationViewController as! PhotosView
            let cell = sender as! MainImageCell
            photosVC.photosData = cell.photosData
            photosVC.startIndex = buffer[tableView.indexPathForCell(cell)!.section]
        }
    }
    

}
