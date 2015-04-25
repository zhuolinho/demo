//
//  MyInfoViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/13.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MyInfoViewController: UITableViewController, UIActionSheetDelegate, APIProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var wxID: UILabel!
    @IBOutlet weak var sign: UILabel!
    @IBOutlet weak var gender: UILabel!
    var api = API()
    var imagePicker = UIImagePickerController()
    var profilePhoto = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        api.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        nickName.text = API.userInfo.nickname
        userName.text = API.userInfo.username
        wxID.text = API.userInfo.wxID
        if API.userInfo.signature == "" {
            sign.text = "未设置"
        }
        else{
            sign.text = API.userInfo.signature
        }
        if API.userInfo.gender ==  "M" {
            gender.text = "男"
        }
        else if API.userInfo.gender == "F" {
            gender.text = "女"
        }
        else {
            gender.text = "未设置"
        }
        var avatarImage = UIImageView(frame: CGRect(x: self.view.bounds.width-95, y: 10, width: 60, height: 60))
        avatarImage.image = API.userInfo.profilePhoto
        avatarImage.layer.cornerRadius = 30
        avatarImage.layer.masksToBounds = true
        self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.addSubview(avatarImage)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var section = indexPath.section
        var row = indexPath.row
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if section == 0 && row == 0 {
            var changeAvatarActionSheet = UIActionSheet()
            changeAvatarActionSheet.title = "更换头像"
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            if buttonIndex == 0 {//拍照
                imagePicker.allowsEditing = true;
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                
                self.presentViewController(imagePicker, animated:true, completion:nil)
            }
            if buttonIndex == 1 {//图片库
                imagePicker.allowsEditing = true;
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                
                self.presentViewController(imagePicker, animated:true, completion:nil)
            }
        }
        else {
            if buttonIndex == 0 {//图片库
                imagePicker.allowsEditing = true;
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                self.presentViewController(imagePicker, animated:true, completion:nil)
            }
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        var height = chosenImage.size.height
        var width = chosenImage.size.width
        if height > width {
            width = 150.0*width/height
            height = 150
        }
        else {
            height = 150.0*height/width
            width = 150
        }
        var rect = CGRectMake(0, 0, width, height)
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        chosenImage.drawInRect(rect)
        profilePhoto = API.userInfo.profilePhoto!
        API.userInfo.profilePhoto = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        api.setAvatar()
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let photoUrl = data["result"] as! NSString //sss
        API.userInfo.profilePhotoUrl = photoUrl as String
        dispatch_async(dispatch_get_main_queue(), {
            self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        let alert = UIAlertView(title: "上传失败", message: "", delegate: nil, cancelButtonTitle: "确定")
        alert.show()
        API.userInfo.profilePhoto = profilePhoto
        dispatch_async(dispatch_get_main_queue(), {
            self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    // MARK: - Table view data source

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
