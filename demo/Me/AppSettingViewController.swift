//
//  AppSettingViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/13.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class AppSettingViewController: UITableViewController, UIAlertViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            if indexPath.row == 0{
                var alert = UIAlertView(title: "登出后需要重新登录", message: "", delegate: self, cancelButtonTitle: "登出", otherButtonTitles: "取消")
                alert.show()
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 0{
            API.userInfo.tokenValid = false
            API.userInfo.token = ""
            API.userInfo.profilePhoto = UIImage(named: "DefaultAvatar")
            API.userInfo.profilePhotoUrl = ""
            EaseMob.sharedInstance().chatManager.asyncLogoff()
            let mainStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let auth = mainStoryboard.instantiateInitialViewController() as UIViewController
            self.tabBarController?.selectedIndex = 0
            self.presentViewController(auth, animated: true, completion: nil)
            self.navigationController?.popToRootViewControllerAnimated(true)
            
        }
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
