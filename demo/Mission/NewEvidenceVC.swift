//
//  NewEvidenceVC.swift
//  demo
//
//  Created by HoJolin on 15/4/18.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreLocation
import MapKit

class NewEvidenceVC: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, APIProtocol, UIAlertViewDelegate  {
    
    var senderInfo = [NSObject : AnyObject]()
    var missionInfo = NSDictionary()
    var locationManger = CLLocationManager()
    var picArray = [UIImage]()
    var picDate = [String]()
    let imagePicker = UIImagePickerController()
    var deleteRow = 0
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var apis = [API]()
    var url = Dictionary<Int, String>()
    let addEvidence = API()
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var picCollection: UICollectionView!
    @IBOutlet weak var sloganTF: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBAction func backButtonClick(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManger.startUpdatingLocation()
        navigationController?.title = "发布证据"
        let blankView = UIView(frame: CGRectZero)
        tableView.tableFooterView = blankView
        var commitButton = UIButton(frame: CGRect(x: 0, y: view.bounds.height - 124, width: view.bounds.width, height: 60))
        commitButton.setTitle("发布证据", forState: UIControlState.Normal)
        commitButton.backgroundColor = UIColor.orangeColor()
        commitButton.titleLabel?.textColor = UIColor.whiteColor()
        commitButton.addTarget(self, action: "commitButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(commitButton)
        titleLabel.text = missionInfo["title"] as? String
        contentLabel.text = missionInfo["content"] as? String
        locationManger.delegate = self
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 {
            locationManger.requestWhenInUseAuthorization()
        }
        picCollection.delegate = self
        picCollection.dataSource = self
        imagePicker.delegate = self
        addEvidence.delegate = self
        if senderInfo[UIImagePickerControllerOriginalImage] != nil {
            imagePickerController(UIImagePickerController(), didFinishPickingMediaWithInfo: senderInfo)
        }
        activity.frame.origin = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 - 64)
        activity.hidesWhenStopped = true
        view.addSubview(activity)
        for i in 0...7 {
            apis.append(API())
            apis[i].delegate = self
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        sloganTF.resignFirstResponder()
        tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: true)
        if indexPath.row == picArray.count {
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
            
            changeAvatarActionSheet.showInView(self.tableView)
        }
        else {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("DeletePicViewController") as! DeletePicViewController
            vc.image = picArray[indexPath.row]
            vc.title = String(indexPath.row + 1) + "/" + String(picArray.count)
            vc.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "删除", style: UIBarButtonItemStyle.Done, target: self, action: "deletePic"), animated: true)
            deleteRow = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
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
    func deletePic() {
        picArray.removeAtIndex(deleteRow)
        picDate.removeAtIndex(deleteRow)
        picCollection.reloadData()
        tableView.reloadData()
        navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            if picArray.count > 3 {
                return (view.bounds.width - 60) / 2 + 10
            }
            else {
                return (view.bounds.width - 60) / 4
            }
        }
        else if indexPath.section == 0 && indexPath.row == 0 {
            return 60
        }
        else {
            return 44
        }
    }
    // MARK: - Table view data source
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if picArray.count >= 8 {
            return 8
        }
        else {
            return picArray.count + 1
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
        let imageView = cell.viewWithTag(1) as! UIImageView
        if indexPath.row >= picArray.count {
            imageView.image = UIImage(named: "new_task_07")
        }
        else {
            imageView.image = picArray[indexPath.row]
        }
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - 60) / 4, height: (view.bounds.width - 60) / 4)
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 4
    }
    func commitButtonClick() {
        if picArray.count == 0 {
            let alert = UIAlertView(title: "请上传图片", message: "", delegate: nil, cancelButtonTitle: "确认")
            alert.show()
            return
        }
        if locationLabel.text == "" {
            let alert = UIAlertView(title: "请定位所在位置", message: "", delegate: nil, cancelButtonTitle: "确认")
            alert.show()
            return
        }
        let alert = UIAlertView(title: "确认发布？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "发布")
        alert.tag = 1
        alert.delegate = self
        alert.show()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sloganTF.resignFirstResponder()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 3 {
            self.locationManger.startUpdatingLocation()
        }
    }
    func click() {
        sloganTF.resignFirstResponder()
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        sloganTF.resignFirstResponder()
    }
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (array,error) -> Void in
            if array.count > 0 {
                let placemarks = array as! [CLPlacemark]
                var placemark: CLPlacemark?
                placemark = placemarks[0]
                self.locationManger.stopUpdatingLocation()
                self.locationLabel.text = placemark?.name
            }
            else {
                self.locationLabel.text = "获取失败"
            }
            self.tableView.reloadData()
        })
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationLabel.text = "获取失败"
        tableView.reloadData()
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let newSize = CGSize(width: view.bounds.width * 2, height: chosenImage.size.height / chosenImage.size.width * view.bounds.width * 2)
        UIGraphicsBeginImageContext(newSize)
        chosenImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let editedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        picArray.append(editedImage)
        picker.dismissViewControllerAnimated(true, completion: nil)
        picCollection.reloadData()
        tableView.reloadData()
        let formatExip = NSDateFormatter()
        formatExip.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let formatSever = NSDateFormatter()
        formatSever.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if  info[UIImagePickerControllerReferenceURL] != nil {
            let url = info[UIImagePickerControllerReferenceURL] as! NSURL
            ALAssetsLibrary().assetForURL(url, resultBlock: { (asset) -> Void in
                if asset != nil {
                    if asset.defaultRepresentation().metadata()["{Exif}"] != nil {
                        let exif = asset.defaultRepresentation().metadata()["{Exif}"] as! NSDictionary
                        if exif["DateTimeOriginal"] != nil {
                            let date = formatExip.dateFromString(exif["DateTimeOriginal"] as! String)
                            self.picDate.append(formatSever.stringFromDate(date!))
                        }
                        else {
                            self.picDate.append("*")
                        }
                    }
                    else {
                        self.picDate.append("*")
                    }
                }
                else {
                    self.picDate.append("*")
                }
                }, failureBlock: { (error) -> Void in
                    println(error)
            })
        }
        else {
            let metadata = info[UIImagePickerControllerMediaMetadata] as! NSDictionary
            let exif = metadata["{Exif}"] as! NSDictionary
            let strDate = exif["DateTimeOriginal"] as! String
            let date = formatExip.dateFromString(strDate)
            picDate.append(formatSever.stringFromDate(date!))
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1 {
            if buttonIndex == 1 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activity.startAnimating()
                    self.view.userInteractionEnabled = false
                    self.navigationController?.navigationBar.userInteractionEnabled = false
                    self.navigationController?.interactivePopGestureRecognizer.enabled = false
                })
                if picArray.count > 0 {
                    for i in 0...picArray.count - 1 {
                        apis[i].uploadPic(picArray[i])
                    }
                }
            }
        }
        else if alertView.tag == 2 {
            if buttonIndex == 1 {
                if picArray.count > 0 {
                    for i in 0...picArray.count - 1 {
                        if url[i] == "" {
                            apis[i].uploadPic(picArray[i])
                            url.removeValueForKey(i)
                        }
                    }
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activity.stopAnimating()
                    self.view.userInteractionEnabled = true
                    self.navigationController?.navigationBar.userInteractionEnabled = true
                    self.navigationController?.interactivePopGestureRecognizer.enabled = true
                })
                url.removeAll(keepCapacity: true)
            }
        }
        else if alertView.tag == 3 {
            if buttonIndex == 1 {
                var slogan = "*"
                if sloganTF.text != "" {
                    slogan = sloganTF.text
                }
                var location = "*"
                if locationLabel.text != "" {
                    location = locationLabel.text!
                }
                var pics = ""
                var picTimes = ""
                if picArray.count > 0 {
                    for i in 0...picArray.count - 1 {
                        if i == 0 {
                            pics += url[0]!
                            picTimes += picDate[0]
                        }
                        else {
                            pics += ",\(url[i]!)"
                            picTimes += ",\(picDate[i])"
                        }
                    }
                }
                else {
                    pics = "*"
                    picTimes = "*"
                }
                addEvidence.addEvidence(missionInfo["id"] as! Int, slogan: slogan, pics: pics, picTimes: picTimes, location: location)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activity.stopAnimating()
                    self.view.userInteractionEnabled = true
                    self.navigationController?.navigationBar.userInteractionEnabled = true
                    self.navigationController?.interactivePopGestureRecognizer.enabled = true
                })
                url.removeAll(keepCapacity: true)
            }
        }
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        if api === addEvidence {
            let alert = UIAlertView(title: "上传失败", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "重试")
            alert.tag = 3
            alert.show()
            return
        }
        for i in 0...7 {
            if api === apis[i] {
                url[i] = ""
                if url.count == picArray.count {
                    let alert = UIAlertView(title: "上传失败", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "重试")
                    alert.tag = 2
                    alert.show()
                }
                break
            }
        }
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === addEvidence {
            dispatch_async(dispatch_get_main_queue(), {
                self.activity.stopAnimating()
                self.navigationController?.navigationBar.userInteractionEnabled = true
                self.view.userInteractionEnabled = true
                self.navigationController?.interactivePopGestureRecognizer.enabled = true
                let alert = UIAlertView(title: "发布成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
            return
        }
        for i in 0...7 {
            if api === apis[i] {
                let photoUrl = data["result"] as! String
                url[i] = photoUrl
                if picArray.count > 0 {
                    for i in 0...picArray.count - 1 {
                        if url[i] == nil || url[i] == "" {
                            return
                        }
                    }
                }
                break
            }
        }
        var slogan = "*"
        if sloganTF.text != "" {
            slogan = sloganTF.text
        }
        var location = "*"
        if locationLabel.text != "" {
            location = locationLabel.text!
        }
        var pics = ""
        var picTimes = ""
        if picArray.count > 0 {
            for i in 0...picArray.count - 1 {
                if i == 0 {
                    pics += url[0]!
                    picTimes += picDate[0]
                }
                else {
                    pics += ",\(url[i]!)"
                    picTimes += ",\(picDate[i])"
                }
            }
        }
        else {
            pics = "*"
            picTimes = "*"
        }
        addEvidence.addEvidence(missionInfo["id"] as! Int, slogan: slogan, pics: pics, picTimes: picTimes, location: location)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

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
