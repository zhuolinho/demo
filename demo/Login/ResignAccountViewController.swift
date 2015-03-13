//
//  ResignAccountViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ResignAccountViewController: UIViewController, APIProtocol {
    
    @IBOutlet weak var resignButton: UIButton!
    var phone: String?
    var code : String?
    var api = API()
    var controllerType = RegistrationStep.SetUpAccount
    @IBOutlet weak var usrName: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var pwdConfirm: UITextField!
    @IBAction func touchDown1(sender: UIControl) {
        usrName.resignFirstResponder()
        pwd.resignFirstResponder()
        pwdConfirm.resignFirstResponder()
    }

    @IBAction func resignButtonClick(sender: UIButton) {
        if usrName.text.isEmpty || pwd.text.isEmpty{
            var alert = UIAlertView(title: "名字或密码不能为空", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else if countElements(pwd.text)<6{
            var alert = UIAlertView(title: "密码不能少于6位", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else if pwd.text != pwdConfirm.text{
            var alert = UIAlertView(title: "两次输入密码不一致", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else{
            api.register(usrName.text , phone: phone!, password: pwd.text, authCode: code!)
            self.resignButton.enabled = false
        }
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if controllerType == RegistrationStep.SetUpAccount {
            let res = data["result"] as NSDictionary
            var result = res["token"] as NSString
            if result == "wrong" {
                var alert = UIAlertView(title: "注册失败，请重试", message: nil, delegate: nil, cancelButtonTitle: "OK")
                self.resignButton.enabled = true
                    alert.show()
            }
            else {
                API.userInfo.token = result
                controllerType = RegistrationStep.RefreshUserInfo
                api.getMyInfo()
            }
        }
        else {
            
            let res = data["result"] as NSDictionary
            API.userInfo.username = res["username"] as NSString
            API.userInfo.nickname = res["nickname"] as NSString
            API.userInfo.phone = res["phone"] as NSString
            API.userInfo.gender = res["gender"] as NSString
            API.userInfo.rmb = res["rmb"] as Int
            API.userInfo.id = res["uid"] as Int
            API.userInfo.profilePhotoUrl = res["avatar"] as String
            
            
            EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.username, password: "123456", completion: {
                (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
//                println(loginInfo)
                if (error == nil) {
                    API.userInfo.tokenValid = true
                    self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    API.userInfo.tokenValid = false
                    EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.phone, password: "123456", completion: {
                        (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
//                        println(error)
                        if (error == nil) {
                            API.userInfo.tokenValid = true
                            self.presentingViewController!.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            
                        }
                        }, onQueue: nil)
                }
                }, onQueue: nil)
            //APService.setTags(NSSet(array: [API.userInfo.username]), alias: API.userInfo.username, callbackSelector: "setTags:", target: self)
            
        }

    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
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
