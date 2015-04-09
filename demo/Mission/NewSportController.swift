//
//  NewSportController.swift
//  demo
//
//  Created by HoJolin on 15/4/6.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreLocation
import MapKit

class NewSportController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    @IBOutlet weak var sloganTF: UITextField!
    @IBOutlet weak var picCollection: UICollectionView!
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var meneyTextField: UITextField!
    
    var imagePicker = UIImagePickerController()
    var picker = UIPickerView()
    var picArray = [UIImage]()
    var picDate = [String]()
    var deleteRow = 0
    var locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var blankView = UIView(frame: CGRectZero)
        tableView.tableFooterView = blankView
        var commitButton = UIButton(frame: CGRect(x: 0, y: view.bounds.height - 124, width: view.bounds.width, height: 60))
        commitButton.setTitle("发布任务", forState: UIControlState.Normal)
        commitButton.backgroundColor = UIColor.orangeColor()
        commitButton.titleLabel?.textColor = UIColor.whiteColor()
        view.addSubview(commitButton)
        picker = UIPickerView(frame: CGRect(x: 0, y: view.bounds.height - 286, width: view.bounds.width, height: 162))
        picker.backgroundColor = UIColor.whiteColor()
        picker.dataSource = self
        picker.delegate = self
        picker.hidden = true
        view.addSubview(picker)
        picCollection.dataSource = self
        picCollection.delegate = self
        imagePicker.delegate = self
        locationManger.delegate = self
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 {
            locationManger.requestWhenInUseAuthorization()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timesLabel.text = String(row)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 3 {
            if picArray.count > 3 {
                return (view.bounds.width - 60) / 2 + 10
            }
            else {
                return (view.bounds.width - 60) / 4
            }
        }
        else if indexPath.section == 0 && indexPath.row == 0 {
            return 50
        }
        else {
            return 44
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        meneyTextField.resignFirstResponder()
        sloganTF.resignFirstResponder()
        if indexPath.section == 0 && indexPath.row == 1 {
            if picker.hidden {
                picker.hidden = false
            }
            else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                picker.hidden = true
            }
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            picker.hidden = true
            if indexPath.section == 0 && indexPath.row == 4 {
                self.locationManger.startUpdatingLocation()
            }
        }
    }
    // MARK: - Table view data source
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(row)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count + 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - 60) / 4, height: (view.bounds.width - 60) / 4)
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
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        meneyTextField.resignFirstResponder()
        sloganTF.resignFirstResponder()
        tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: true)
        picker.hidden = true
        if indexPath.row == collectionView.numberOfItemsInSection(0) - 1 {
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
//            vc.navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "删除", style: UIBarButtonItemStyle.Done, target: self, action: "deletePic: indexPath.row")
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picArray.append(chosenImage)
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        picCollection.reloadData()
        tableView.reloadData()
        let formatExip = NSDateFormatter()
        formatExip.dateFormat = "yyyy:MM:dd hh:mm:ss"
        let formatSever = NSDateFormatter()
        formatSever.dateFormat = "yyyy-MM-dd hh:mm:ss"
        if  info[UIImagePickerControllerReferenceURL] != nil {
            let url = info[UIImagePickerControllerReferenceURL] as! NSURL
            ALAssetsLibrary().assetForURL(url, resultBlock: { (asset) -> Void in
                if asset.defaultRepresentation().metadata()["{Exif}"] != nil {
                    let exif = asset.defaultRepresentation().metadata()["{Exif}"] as! NSDictionary
                    if exif["DateTimeOriginal"] != nil {
                        let date = formatExip.dateFromString(exif["DateTimeOriginal"] as! String)
                        self.picDate.append(formatSever.stringFromDate(date!))
                    }
                    self.picDate.append("*")
                }
                self.picDate.append("*")
                }, failureBlock: { (error) -> Void in
                println(error)
            })
        }
        else {
            let metadata = info[UIImagePickerControllerMediaMetadata] as! NSDictionary
            let exif = metadata["{Exif}"] as! NSDictionary
            let date = formatExip.dateFromString(exif["DateTimeOriginal"] as! String)
            picDate.append(formatSever.stringFromDate(date!))
        }
    }
    func deletePic() {
        picArray.removeAtIndex(deleteRow)
        picDate.removeAtIndex(deleteRow)
        picCollection.reloadData()
        tableView.reloadData()
        navigationController?.popViewControllerAnimated(true)
    }
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (array,error) -> Void in
            if array.count > 0 {
                let placemarks = array as! [CLPlacemark]
                var placemark: CLPlacemark?
                placemark = placemarks[0]
                self.locationManger.stopUpdatingLocation()
                self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))?.detailTextLabel?.text = placemark?.name
            }
            else {
                self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))?.detailTextLabel?.text = "获取失败"
            }
            self.tableView.reloadData()
        })
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))?.detailTextLabel?.text = "获取失败"
        tableView.reloadData()
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
