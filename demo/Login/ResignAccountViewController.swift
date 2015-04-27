//
//  ResignAccountViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ResignAccountViewController: UIViewController, APIProtocol, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var phone: String?
    let api = API()
    var controllerType = RegistrationStep.SetUpAccount
    var passWord: String?
    var gender = "F"
    var imagePicker = UIImagePickerController()
    var avatar = UIImage(named: "DefaultAvatar")
    
    @IBOutlet weak var resignButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usrName: UITextField!
    @IBOutlet weak var pwdConfirm: UITextField!
    @IBOutlet weak var feMaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    
    @IBAction func avatarButtonClick(sender: UIButton) {
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
        
        changeAvatarActionSheet.showInView(view)
    }
    
    @IBAction func maleButtonClick(sender: UIButton) {
        maleButton.setImage(UIImage(named: "register_14"), forState: UIControlState.Normal)
        feMaleButton.setImage(UIImage(named: "register_13"), forState: UIControlState.Normal)
        gender = "M"
    }
    
    @IBAction func femaleButtonClick(sender: UIButton) {
        maleButton.setImage(UIImage(named: "register_13"), forState: UIControlState.Normal)
        feMaleButton.setImage(UIImage(named: "register_14"), forState: UIControlState.Normal)
        gender = "F"
    }
    
    @IBAction func touchDown1(sender: UIControl) {
        usrName.resignFirstResponder()
        pwdConfirm.resignFirstResponder()
    }

    @IBAction func resignButtonClick(sender: UIButton) {
        if usrName.text.isEmpty {
            var alert = UIAlertView(title: "昵称不能为空", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else{
            api.register(usrName.text, phone: phone!, password: passWord!, gender: gender, avatar: avatar, signature: pwdConfirm.text)
            self.resignButton.enabled = false
            self.navigationController?.navigationBar.userInteractionEnabled = false
        }
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
        avatar = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        avatarButton.setImage(avatar, forState: UIControlState.Normal)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if controllerType == RegistrationStep.SetUpAccount {
            let res = data["result"] as! NSDictionary
            var result = res["token"] as! NSString
            if result == "wrong" {
                var alert = UIAlertView(title: "注册失败，请重试", message: nil, delegate: nil, cancelButtonTitle: "OK")
                self.resignButton.enabled = true
                self.navigationController?.navigationBar.userInteractionEnabled = true
                    alert.show()
            }
            else {
                API.userInfo.token = result as String
                controllerType = RegistrationStep.RefreshUserInfo
                api.getMyInfo()
            }
        }
        else {

            let res = data["result"] as! NSDictionary
            API.userInfo.username = res["username"] as! String
            API.userInfo.nickname = res["nickname"] as! String
            API.userInfo.phone = res["phone"] as! String
            API.userInfo.gender = res["gender"] as! String
            API.userInfo.rmb = res["rmb"] as! Int
            API.userInfo.id = res["uid"] as! Int
            API.userInfo.profilePhotoUrl = res["avatar"] as! String
            API.userInfo.weixin = res["weixin"] as! String
            API.userInfo.profilePhoto = avatar
            API.userInfo.signature = pwdConfirm.text
            
            EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.username, password: "123456", completion: {
                (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                if (error == nil) {
                    API.userInfo.tokenValid = true
                    self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    API.userInfo.tokenValid = false
                    EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.phone, password: "123456", completion: {
                        (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                        if (error == nil) {
                            API.userInfo.tokenValid = true
                            self.presentingViewController!.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            
                        }
                        }, onQueue: nil)
                }
                }, onQueue: nil)
            APService.setTags([API.userInfo.username], alias: API.userInfo.username, callbackSelector: "setTags:", target: self)
            
        }

    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        var alert = UIAlertView(title: "注册失败，请重试", message: nil, delegate: nil, cancelButtonTitle: "OK")
        self.resignButton.enabled = true
        self.navigationController?.navigationBar.userInteractionEnabled = true
        alert.show()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        imagePicker.delegate = self
        avatarButton.layer.cornerRadius = 56.5
        avatarButton.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
