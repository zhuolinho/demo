//
//  NewsViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/12.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController, APIProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    @IBOutlet weak var titleButton: UIButton!
    var requesMore = API()
    var news = [NSDictionary]()
    var skip = -1
    var buffer = [Int]()
    var isRequesing = false
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let auth = mainStoryboard.instantiateInitialViewController() as UIViewController
            self.presentViewController(auth, animated: true, completion: nil)
        }
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
        return 3
    }
//
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section < news.count
        {
            let stuct = news[indexPath.section]["struct"] as NSDictionary
            let pics = stuct["pics"] as [NSDictionary]
            if indexPath.row == 0 {
                return 44
            }
            else if indexPath.row == 1 {
                return self.view.bounds.width
            }
            else if indexPath.row == 2 {
                if pics.count > 1 {
                    return self.view.bounds.width / 4
                }
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section < news.count {
            let stuct = news[indexPath.section]["struct"] as NSDictionary
            let pics = stuct["pics"] as [NSDictionary]
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as TitleCell
                cell.timeLabel.text = stuct["createTime"] as? String
                cell.nameLabel.text = stuct["nickname"] as? String
                let url = stuct["avatar"] as String
                if PicDic.picDic[url] != nil {
                    cell.avatar.image = PicDic.picDic[url]
                }
                else {
                    cell.avatar.image = UIImage(named: "DefaultAvatar")
                }           
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("MainImageCell", forIndexPath: indexPath) as MainImageCell
                let url =  pics[buffer[indexPath.section]]["url"] as String
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
                let cell = tableView.dequeueReusableCellWithIdentifier("PickPicCell", forIndexPath: indexPath) as PickPicCell
                cell.pickCollectionView.tag = indexPath.section
                cell.pickCollectionView.delegate = self
                cell.dataSource = pics
                cell.pickCollectionView.reloadData()
                return cell
            }

        }
        return UITableViewCell()
        
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let stuct = news[indexPath.section]["struct"] as NSDictionary
        let pics = stuct["pics"] as [NSDictionary]
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
        let stuct = news[collectionView.tag]["struct"] as NSDictionary
        let pics = stuct["pics"] as [NSDictionary]
        let url = pics[indexPath.row]["url"] as String
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: collectionView.tag)) as MainImageCell
        cell.mainImageView.image = PicDic.picDic[url]
        buffer[collectionView.tag] = indexPath.row
    }
    
    func refreshing() {
        if !isRequesing {
            requesMore.getMissionsAndEvidences(0)
            skip = 0
            isRequesing = true
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
            })
            if skip == 0 {
                buffer.removeAll(keepCapacity: true)
                news.removeAll(keepCapacity: true)
            }
            var res = data["result"] as NSArray
            if res.count > 0 {
                var items = [NSDictionary]()
                for it in res {
                    items.append(it as NSDictionary)
                    buffer.append(0)
                    let stuct = it["struct"] as NSDictionary
                    let avatar = ["url": stuct["avatar"] as String]
                    var pics = stuct["pics"] as [NSDictionary]
                    pics.append(avatar)
                    for pic in pics {
                        let url = pic["url"] as String
                        if PicDic.picDic[url] == nil {
                            let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                            let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                if error? == nil {
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
            let photosVC = segue.destinationViewController as PhotosView
            let cell = sender as MainImageCell
            photosVC.photosData = cell.photosData
            photosVC.startIndex = buffer[tableView.indexPathForCell(cell)!.section]
        }
    }
    

}
