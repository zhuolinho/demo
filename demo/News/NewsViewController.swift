//
//  NewsViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/12.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController, APIProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var viewa = UIView()
    @IBOutlet weak var titleButton: UIButton!
    @IBAction func filterClick(sender: UIBarButtonItem) {
        if viewa.hidden {
            viewa.hidden = false
        }
        else {
            viewa.hidden = true
        }
    }
    var requesMore = API()
    var news = [NSDictionary]()
    var skip = -1
    var buffer = [Int]()
    var isRequesing = false
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    override func viewDidLoad() {
        super.viewDidLoad()
        viewa = UIView(frame: CGRect(x: view.bounds.width - 100, y: 40, width: 0, height: 0))
        navigationController?.navigationBar.addSubview(viewa)
        viewa.addSubview(UIImageView(image: UIImage(named: "moment1_07")))
        requesMore.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshing", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshing()
        titleButton.addTarget(self, action: "refreshing", forControlEvents: UIControlEvents.TouchDownRepeat)
        activity.hidesWhenStopped = true
        self.tableView.tableFooterView = activity
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if (!API.userInfo.tokenValid && API.userInfo.token == ""){
            let mainStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let auth = mainStoryboard.instantiateInitialViewController() as! UIViewController
            self.presentViewController(auth, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewa.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var add = 0
        if section < news.count {
            let stuct = news[section]["struct"] as! NSDictionary
            let comment = stuct["comment"] as! [NSDictionary]
            if comment.count > 5 {
                add = 6
            }
            else {
                add = comment.count
            }
        }
        return 7 + add
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
                return self.view.bounds.width
            }
            else if indexPath.row == 2 {
                return 0
            }
            else if indexPath.row == 3 {
                return 60
            }
            else if indexPath.row == 4 {
                return 44
            }
            else if indexPath.row == 5 {
                if news[indexPath.section]["type"] as? String == "mission" {
                    if stuct["slogan"] as? String != "*" {
                        return 44
                    }
                    else {
                        return 0
                    }
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
                let url =  pics[buffer[indexPath.section]]["url"] as! String
                cell.photosData = pics
                if PicDic.picDic[url] != nil {
                    cell.mainImageView.image = PicDic.picDic[url]
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
                if type == "mission" {
                    cell.backgroundColor = UIColor.orangeColor()
                    cell.typeLabel.text = "任务剩余时间"
                    cell.meneyLabel.text = String(charge)
                }
                else {
                    cell.backgroundColor = UIColor.blackColor()
                    cell.typeLabel.text = "证据拍摄时间"
                    cell.meneyLabel.text = String(charge)
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
                return cell
            }
            else if indexPath.row > 6 && indexPath.row < 12 {
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
                let comment = comments[indexPath.row - 7]
                let nickname = comment["nickname"] as! String
                let content = comment["content"] as! String
                cell.commentLabel.text = nickname + "：" + content
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
            else if indexPath.row == 12 {
                let cell = tableView.dequeueReusableCellWithIdentifier("MoreCommentsCell", forIndexPath: indexPath) as! MoreCommentsCell
                return cell
            }

        }
        return UITableViewCell()
        
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == news.count - 1 && skip != -1 {
            if !isRequesing {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activity.startAnimating()
                })
                requesMore.getMissionsAndEvidences(skip)
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
                self.tableView.setContentOffset(CGPointMake(0, -60), animated: true)
            }
            requesMore.getMissionsAndEvidences(0)
            skip = 0
            isRequesing = true
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewa.hidden = true
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
            })
            if skip == 0 {
                buffer.removeAll(keepCapacity: true)
                news.removeAll(keepCapacity: true)
            }
            var res = data["result"] as! NSArray
            if res.count > 0 {
                var items = [NSDictionary]()
                for it in res {
                    items.append(it as! NSDictionary)
                    buffer.append(0)
                    let stuct = it["struct"] as! NSDictionary
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
