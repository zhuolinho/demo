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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requesMore.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshing", forControlEvents: UIControlEvents.ValueChanged)
        refreshing()
        titleButton.addTarget(self, action: "titleButtonDoubleClick", forControlEvents: UIControlEvents.TouchDownRepeat)
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if API.userInfo.nickname != "" {
            titleButton.setTitle(API.userInfo.nickname, forState: UIControlState.Normal)
        }
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
        if section == news.count {
            return 1
        }
        else {
            return 3
        }
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
                var url = stuct["avatar"] as String
                if PicDic.picDic[url] == nil {
                    cell.avatar.image = UIImage()
                    let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                    let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                    let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error? == nil {
                            var rawImage: UIImage? = UIImage(data: data)
                            let img: UIImage? = rawImage
                            if img != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    cell.avatar.image = img
                                    PicDic.picDic[url] = img
                                })
                            }
                            else{
                                cell.avatar.image = UIImage(named: "DefaultAvatar")
                            }
                        }
                        else{
                            cell.avatar.image = UIImage(named: "DefaultAvatar")
                        }
                    })
                }
                else {
                    cell.avatar.image = PicDic.picDic[url]
                }
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("MainImageCell", forIndexPath: indexPath) as MainImageCell
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
        if indexPath.section == news.count - 1 {
            if !isRequesing {
                requesMore.getMissionsAndEvidences(skip)
                isRequesing = true
            }
        }
        else if indexPath.row == 1 {
            let mainImagecell = cell as MainImageCell
            let stuct = news[indexPath.section]["struct"] as NSDictionary
            let pics = stuct["pics"] as [NSDictionary]
            let url =  pics[buffer[indexPath.section]]["url"] as String
            if PicDic.picDic[url] == nil {
                mainImagecell.mainImageView.image = UIImage()
            }
            else {
                mainImagecell.mainImageView.image = PicDic.picDic[url]
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
        requesMore.getMissionsAndEvidences(0)
        skip = 0
        isRequesing = true
    }
    
    func titleButtonDoubleClick() {
        refreshing()
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        if refreshControl?.refreshing == true {
            refreshControl?.endRefreshing()
        }
        skip = -1
        isRequesing = false
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === requesMore {
            isRequesing = false
            if refreshControl?.refreshing == true {
                refreshControl?.endRefreshing()
            }
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
                }
                news += items
                var range = NSMakeRange(self.skip, items.count)
                var indexSet = NSIndexSet(indexesInRange: range)
                self.skip += items.count
                dispatch_async(dispatch_get_main_queue(), {
                    if range.location == 0 {
                        self.tableView.reloadData()
                    }
                    else {
                        self.tableView.beginUpdates()
                        self.tableView.insertSections(indexSet, withRowAnimation:UITableViewRowAnimation.Fade)
                        self.tableView.endUpdates()
                    }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
