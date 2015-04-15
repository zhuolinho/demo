//
//  MyMissionsVC.swift
//  demo
//
//  Created by HoJolin on 15/4/15.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MyMissionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, APIProtocol {

    @IBOutlet weak var viewTable: UITableView!
    
    @IBOutlet weak var missionsTable: UITableView!
    
    let api = API()
    var missions = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewTable.dataSource = self
        viewTable.delegate = self
        missionsTable.dataSource = self
        missionsTable.delegate = self
        api.delegate = self
        let blankView = UIView(frame: CGRectZero)
        missionsTable.tableFooterView = blankView
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        api.getMyMissions(0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === viewTable {
            return 2
        }
        else {
            return missions.count
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView === viewTable {
            if indexPath.row == 0 {
                return 265
            }
            else {
                return 55
            }
        }
        else {
            return 47
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView === viewTable {
            if indexPath.row == 0 {
                let cell =  tableView.dequeueReusableCellWithIdentifier("ImageViewCell", forIndexPath: indexPath) as! UITableViewCell
                let imageView = cell.viewWithTag(1) as! UIImageView
                imageView.image = UIImage(named: "DefaultAvatar")
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MissionCell", forIndexPath: indexPath) as! UITableViewCell
            if indexPath.row < missions.count {
                let titleLabel = cell.viewWithTag(1) as! UILabel
                let contentLabel = cell.viewWithTag(2) as! UILabel
                titleLabel.text = missions[indexPath.row]["title"] as? String
                contentLabel.text = missions[indexPath.row]["content"] as? String
                let scrollView = cell.viewWithTag(5) as! UIScrollView
                scrollView.contentSize = CGSize(width: view.bounds.width + 108, height: 47)
                let selectButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 47))
                selectButton.addTarget(self, action: "selectButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
                selectButton.tag = indexPath.row
                scrollView.addSubview(selectButton)
                let addButton = UIButton(frame: CGRect(x: view.bounds.width, y: 0, width: 54, height: 47))
                addButton.setImage(UIImage(named: "addButton"), forState: .Normal)
                addButton.addTarget(self, action: "addButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
                addButton.tag = indexPath.row
                scrollView.addSubview(addButton)
                let deleteButton = UIButton(frame: CGRect(x: view.bounds.width + 54, y: 0, width: 54, height: 47))
                deleteButton.setImage(UIImage(named: "deleteButton"), forState: .Normal)
                deleteButton.addTarget(self, action: "deleteButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
                deleteButton.tag = indexPath.row
                scrollView.addSubview(deleteButton)
                return cell
            }
            return UITableViewCell()
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("fuck")
    }
    func addButtonClick() {
        println("add")
    }
    func deleteButtonClick() {
        println("delete")
    }
    func selectButtonClick() {
        println("select")
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! [NSDictionary]
        missions.removeAll(keepCapacity: true)
        for item in res {
            missions.append(item)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.missionsTable.reloadData()
        })
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
