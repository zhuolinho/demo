//
//  AddFriendTableVC.swift
//  demo
//
//  Created by HoJolin on 15/4/12.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class AddFriendTableVC: UITableViewController, APIProtocol, UISearchBarDelegate {
    
    let api = API()
    var friendInfo = [NSDictionary]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func searchButtonClick(sender: UIBarButtonItem) {
        if searchBar.text != "" {
            friendInfo.removeAll(keepCapacity: true)
            api.searchFriend(searchBar.text)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var blankview = UIView(frame: CGRectZero)
        tableView.tableFooterView = blankview
        api.delegate = self
        searchBar.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text != "" {
            friendInfo.removeAll(keepCapacity: true)
            api.searchFriend(searchBar.text)
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("FriendInfoViewController") as! FriendInfoViewController
        let url = friendInfo[0]["avatar"] as! String
        vc.nickName = friendInfo[0]["nickname"] as! String
        vc.userName = friendInfo[0]["username"] as! String
        if PicDic.picDic[url] == nil {
            vc.avatar = UIImage(named: "DefaultAvatar")
        }
        else {
            vc.avatar = PicDic.picDic[url]
        }
        vc.avatarURL = url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return friendInfo.count
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        if errno == 3 {
            let alert = UIAlertView(title: "无此用户", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
        else {
            let alert = UIAlertView(title: "网络错误", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! NSDictionary
        friendInfo.removeAll(keepCapacity: true)
        friendInfo.append(res)
        let url = res["avatar"] as! String
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
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
        // Configure the cell...
        let textLabel = cell.viewWithTag(1) as! UILabel
        let imageView = cell.viewWithTag(2) as! UIImageView
        textLabel.text = friendInfo[0]["nickname"] as? String
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        let url = friendInfo[0]["avatar"] as! String
        if PicDic.picDic[url] == nil {
            imageView.image = UIImage(named: "DefaultAvatar")
        }
        else {
            imageView.image = PicDic.picDic[url]
        }
        return cell
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
