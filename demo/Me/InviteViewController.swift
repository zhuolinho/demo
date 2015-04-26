//
//  InviteViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/26.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit
import MessageUI

class InviteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    
    var sortArray = [([String : String])]()
    var mark = [NSIndexPath : Bool]()
    
    @IBAction func inviteButtonClick(sender: UIButton) {
        var numArray = [String]()
        for section in 0..<sortArray.count {
            var i = 0
            while sortArray[section]["Phone\(i)"] != nil {
                if mark[NSIndexPath(forRow: i, inSection: section)]! {
                    numArray.append(sortArray[section]["Phone\(i)"]!)
                }
                i++
            }
        }
        if numArray.count > 0 && MFMessageComposeViewController.canSendText() {
            let messageViewController = MFMessageComposeViewController()
            messageViewController.messageComposeDelegate = self
            messageViewController.recipients = numArray
            messageViewController.body = "法克鱿"
            self.presentViewController(messageViewController, animated: true, completion: nil)
        }
    }
    @IBAction func allButtonClick(sender: UIButton) {
        for section in 0..<sortArray.count {
            var i = 0
            while sortArray[section]["Phone\(i)"] != nil {
                mark[NSIndexPath(forRow: i, inSection: section)] = true
                i++
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    @IBAction func buttonClick(sender: UIButton) {
        mark[NSIndexPath(forRow: sender.tag % 1000, inSection: sender.tag / 1000)] = !mark[NSIndexPath(forRow: sender.tag % 1000, inSection: sender.tag / 1000)]!
        if mark[NSIndexPath(forRow: sender.tag % 1000, inSection: sender.tag / 1000)]! {
            sender.setImage(UIImage(named: "invite1_27"), forState: UIControlState.Normal)
        }
        else {
            sender.setImage(UIImage(named: "invite1_21"), forState: UIControlState.Normal)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let blankView = UIView()
        tableView.tableFooterView = blankView
        var array = NSMutableArray(array: getSysContacts())
        sortArray = sortDataSource(array) as! [([String : String])]
        for section in 0..<sortArray.count {
            var i = 0
            while sortArray[section]["Phone\(i)"] != nil {
                mark[NSIndexPath(forRow: i, inSection: section)] = false
                i++
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var i = 0
        while sortArray[section]["Phone\(i)"] != nil {
            i++
        }
        return i
    }
    func sortDataSource(dataArray: NSMutableArray) -> NSArray{
        var array = dataArray.sortedArrayUsingComparator({
            (obj1: AnyObject!, obj2: AnyObject!) -> NSComparisonResult in
            var firstLetter1 = ChineseToPinyin.pinyinFromChineseString(obj1.objectForKey("fullName")as! String)
            var firstLetter2 = ChineseToPinyin.pinyinFromChineseString(obj2.objectForKey("fullName")as! String)
            return firstLetter1.caseInsensitiveCompare(firstLetter2)
        })
        return array
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InviteCell", forIndexPath: indexPath) as! InviteCell
        cell.nameLabel.text = sortArray[indexPath.section]["fullName"]
        cell.numLabel.text = sortArray[indexPath.section]["Phone\(indexPath.row)"]
        cell.selectButton.tag = indexPath.section * 1000 + indexPath.row
        if mark[indexPath]! {
            cell.selectButton.setImage(UIImage(named: "invite1_27"), forState: UIControlState.Normal)
        }
        else {
            cell.selectButton.setImage(UIImage(named: "invite1_21"), forState: UIControlState.Normal)
        }
        // Configure the cell...
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        if result.value == 1 {
            let alert = UIAlertView(title: "邀请成功", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
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
