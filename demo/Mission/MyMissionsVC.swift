//
//  MyMissionsVC.swift
//  demo
//
//  Created by HoJolin on 15/4/15.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MyMissionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, APIProtocol, SWTableViewCellDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var viewTable: UITableView!
    
    @IBOutlet weak var missionsTable: UITableView!
    
    let api1 = API()
    var missions = [NSDictionary]()
    let api2 = API()
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let formatSever = NSDateFormatter()
    var mark = 0
    var imagePicker = UIImagePickerController()
    var temp = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewTable.dataSource = self
        viewTable.delegate = self
        missionsTable.dataSource = self
        missionsTable.delegate = self
        api1.delegate = self
        api2.delegate = self
        let blankView = UIView(frame: CGRectZero)
        missionsTable.tableFooterView = blankView
        activity.frame.origin = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 + 160)
        activity.hidesWhenStopped = true
        view.addSubview(activity)
        formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatSever.timeZone = NSTimeZone(forSecondsFromGMT: 8 * 3600)
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activity.startAnimating()
        api1.getMyMissions(0)
        navigationController!.tabBarItem.title = "任务"
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
                let markView = cell.viewWithTag(2) as! UIImageView
                markView.hidden = true
                if missions.count > mark {
                    let pics = missions[mark]["pics"] as! [NSDictionary]
                    if pics.count > 0 {
                        let url = pics[0]["url"] as! String
                        if PicDic.picDic[url] != nil {
                            imageView.image = PicDic.picDic[url]
                        }
                        else {
                            imageView.image = UIImage(named: "noimage2")
                        }
                    }
                    else {
                        imageView.image = UIImage(named: "noimage1")
                    }
                    if missions[mark]["status"] as! Int == 2 {
                        markView.hidden = false
                        markView.image = UIImage(named: "v_03")
                    }
                    else if missions[mark]["status"] as! Int == 3 {
                        markView.hidden = false
                        markView.image = UIImage(named: "mission12_03")
                    }
                    else {
                        markView.hidden = true
                    }
                }
                else {
                    imageView.image = UIImage()
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! UITableViewCell
                let timeLabel = cell.viewWithTag(1) as! UILabel
                let chargeLabel = cell.viewWithTag(2) as! UILabel
                if missions.count <= mark {
                    timeLabel.text = ""
                    chargeLabel.text = ""
                }
                else {
                    let endTime = formatSever.dateFromString(missions[mark]["endTime"] as! String)
                    let hour = Int(endTime!.timeIntervalSinceNow / 3600)
                    let charge = missions[mark]["charge"] as! Int
                    if missions[mark]["status"] as! Int != 1 && missions[mark]["status"] as! Int != 0 {
                        cell.backgroundColor = UIColor.lightGrayColor()
                        timeLabel.text = "已完成"
                    }
                    else {
                        cell.backgroundColor = UIColor.orangeColor()
                        timeLabel.text = "\(hour / 24)天\(hour % 24)小时"
                    }
                    chargeLabel.text = String(charge)
                }
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MissionCell", forIndexPath: indexPath) as! MissionCell
            if indexPath.row < missions.count {
                var rightButtons = [UIButton]()
                let addButton = UIButton()
                if missions[indexPath.row]["status"] as! Int == 0 || missions[indexPath.row]["status"] as! Int == 1 {
                    addButton.setImage(UIImage(named: "addButton"), forState: UIControlState.Normal)
                    addButton.backgroundColor = UIColor.clearColor()
                    rightButtons.append(addButton)
                }
                let deleteButton = UIButton()
                deleteButton.setImage(UIImage(named: "deleteButton"), forState: UIControlState.Normal)
                deleteButton.backgroundColor = UIColor.clearColor()
                rightButtons.append(deleteButton)
                cell.setRightUtilityButtons(rightButtons, withButtonWidth: 54)
                cell.titleLabel.text = missions[indexPath.row]["title"] as? String
                cell.contentLabel.text = missions[indexPath.row]["content"] as? String
                cell.delegate = self
                cell.tag = indexPath.row
                return cell
            }
            return UITableViewCell()
        }
    }
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        if index == 0 && (missions[cell.tag]["status"] as! Int == 0 || missions[cell.tag]["status"] as! Int == 1) {
            var changeAvatarActionSheet = UIActionSheet()
            changeAvatarActionSheet.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                changeAvatarActionSheet.addButtonWithTitle("拍摄照片")
                changeAvatarActionSheet.addButtonWithTitle("图片库中选取")
                changeAvatarActionSheet.addButtonWithTitle("取消")
                changeAvatarActionSheet.cancelButtonIndex = 2
            }
            else {
                changeAvatarActionSheet.addButtonWithTitle("图片库中选取")
                changeAvatarActionSheet.addButtonWithTitle("取消")
                changeAvatarActionSheet.cancelButtonIndex = 1
            }
            temp = cell.tag
            changeAvatarActionSheet.showInView(view)
        }
        else {
            let alert = UIAlertView(title: "确认删除？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确认")
            alert.tag = cell.tag
            alert.show()
        }
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            if buttonIndex == 0 {//拍照
                //                imagePicker.allowsEditing = true;
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                
                self.presentViewController(imagePicker, animated:true, completion:nil)
            }
            if buttonIndex == 1 {//图片库
                //                imagePicker.allowsEditing = true;
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                
                self.presentViewController(imagePicker, animated:true, completion:nil)
            }
        }
        else {
            if buttonIndex == 0 {//图片库
                //                imagePicker.allowsEditing = true;
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                self.presentViewController(imagePicker, animated:true, completion:nil)
            }
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let vc = storyboard?.instantiateViewControllerWithIdentifier("NewEvidenceVC") as! NewEvidenceVC
        vc.senderInfo = info
        vc.missionInfo = missions[temp]
        navigationController?.pushViewController(vc, animated: true)
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            dispatch_async(dispatch_get_main_queue(), {
                self.activity.startAnimating()
                self.missionsTable.userInteractionEnabled = false
            })
            let mid = missions[alertView.tag]["id"] as! Int
            api2.deleteMission(mid)
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView === missionsTable {
            mark = indexPath.row
            let cell = viewTable.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            let timeLabel = cell!.viewWithTag(1) as! UILabel
            let chargeLabel = cell!.viewWithTag(2) as! UILabel
            let endTime = formatSever.dateFromString(missions[indexPath.row]["endTime"] as! String)
            let charge = missions[indexPath.row]["charge"] as! Int
            let hour = Int(endTime!.timeIntervalSinceNow / 3600)
            if missions[mark]["status"] as! Int != 1 && missions[mark]["status"] as! Int != 0 {
                timeLabel.text = "已完成"
                cell?.backgroundColor = UIColor.lightGrayColor()
            }
            else {
                timeLabel.text = "\(hour / 24)天\(hour % 24)小时"
                cell?.backgroundColor = UIColor.orangeColor()
            }
            chargeLabel.text = String(charge)
            let cell1 = viewTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            let imageView = cell1!.viewWithTag(1) as! UIImageView
            let markView = cell1?.viewWithTag(2) as! UIImageView
            markView.hidden = true
            if missions.count > mark {
                let pics = missions[mark]["pics"] as! [NSDictionary]
                if pics.count > 0 {
                    let url = pics[0]["url"] as! String
                    if PicDic.picDic[url] != nil {
                        imageView.image = PicDic.picDic[url]
                    }
                    else {
                        imageView.image = UIImage(named: "noimage2")
                    }
                }
                else {
                    imageView.image = UIImage(named: "noimage1")
                }
                if missions[mark]["status"] as! Int == 2 {
                    markView.hidden = false
                    markView.image = UIImage(named: "v_03")
                }
                else if missions[mark]["status"] as! Int == 3 {
                    markView.hidden = false
                    markView.image = UIImage(named: "mission12_03")
                }
                else {
                    markView.hidden = true
                }
            }
            else {
                imageView.image = UIImage()
            }
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        if api === api2 {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "删除失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                self.missionsTable.userInteractionEnabled = true
                self.activity.stopAnimating()
            })
        }
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === api1 {
            let res = data["result"] as! [NSDictionary]
            missions.removeAll(keepCapacity: true)
            for item in res {
                missions.append(item)
            }
            mark = 0
            dispatch_async(dispatch_get_main_queue(), {
                self.activity.stopAnimating()
                self.missionsTable.userInteractionEnabled = true
                self.missionsTable.reloadData()
                self.viewTable.reloadData()
                self.activity.stopAnimating()
            })
            if res.count > 0 {
                for it in res {
                    var pics = it["pics"] as! [NSDictionary]
                    if pics.count > 0 {
                        let url = pics[0]["url"] as! String
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
                                            self.viewTable.reloadData()
                                        })
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
        else {
            let res = data["result"] as! Int
            if res == 1 {
                api1.getMyMissions(0)
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "删除成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertView(title: "删除失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    self.missionsTable.userInteractionEnabled = true
                    self.activity.stopAnimating()
                })
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MissionDetailVC" && missions.count > mark {
            let vc = segue.destinationViewController as! MissionDetailVC
            vc.mid = missions[mark]["id"] as! Int
        }
    }


}
