//
//  LoginViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, APIProtocol {
    
    var login = API()
    var refreshUserInfo = API()
    var controllerType = RegistrationStep.Login
    var ifcanceled = false
    var iflogining = false
    var cancelLock = NSLock()
    var loginLock = NSLock()

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usrName: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBAction func touchDown(sender: AnyObject) {
        usrName.resignFirstResponder()
        pwd.resignFirstResponder()
    }
    @IBAction func loginButtonClick(sender: UIButton) {
        if iflogining {
            //println("don't repeatly login")
            return
        } else {
            loginLock.lock()
            iflogining = true
            loginButton.enabled = false
            loginLock.unlock()
        }
        
        if usrName.text.isEmpty || pwd.text.isEmpty {
            var alert = UIAlertView(title: "用户名或密码不能为空", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            iflogining = false
            loginButton.enabled = true
        }
        else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            //YoLock.sharedInstance().lock.lock()
            //println("lock")
            //loginButton.enabled = false
            //loginButton.userInteractionEnabled = false
            login.login(username: usrName.text, password: pwd.text)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        login.delegate = self
        refreshUserInfo.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
        iflogining = false
        loginButton.enabled = true
        var alert = UIAlertView(title: "提示", message: "对不起，暂时不能登录，请稍候重试", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if api === login{
            let res = data["result"] as NSDictionary
            if res["token"] as NSString == "wrong" {
                var alert = UIAlertView(title: "用户名或密码有误", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                //loginButton.userInteractionEnabled = true
                //println("unlock")
                //YoLock.sharedInstance().lock.unlock()
                iflogining = false
                loginButton.enabled = true
            }
            else {
                API.userInfo.token = res["token"] as String
                let userInfoDic: NSDictionary = NSDictionary(dictionary: ["token": API.userInfo.token, "language": API.userInfo.languagePreference, "sound": API.userInfo.messageSound])
                NSUserDefaults.standardUserDefaults().setObject(userInfoDic, forKey: "YoUserInfo")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.cancelLock.lock()
                if self.ifcanceled {
                    self.cancelLock.unlock()
                    iflogining = false
                    loginButton.enabled = true
                    return
                }
                refreshUserInfo.getMyInfo()
                self.cancelLock.unlock()
            }
            //            controllerType = RegistrationStep.RefreshUserInfo
            
        }
        else if api === refreshUserInfo{
            self.cancelLock.lock()
            if self.ifcanceled {
                self.cancelLock.unlock()
                println("canceled")
                iflogining = false
                loginButton.enabled = true
                NSLog("cancelLock")
                return
            }
            cancelLock.unlock()
            
            let res = data["result"] as NSDictionary
            API.userInfo.username = res["username"] as NSString
            API.userInfo.nickname = res["nickname"] as NSString
            API.userInfo.phone = res["phone"] as NSString
            API.userInfo.gender = res["gender"] as NSString
            API.userInfo.rmb = res["rmb"] as Int
            API.userInfo.id = res["uid"] as Int
            API.userInfo.profilePhotoUrl = res["avatar"] as String
            NSLog("refreshUserInfo")
            
            println(res)
            
//            if (res["ifmessage"] as Int) == 1 {
//                API.userInfo.acceptNote = true
//            }
//            else {
//                API.userInfo.acceptNote = false
//            }
            
            println("login huanxin")
            
            //            API.userInfo.languagePreference = res["lang"] as Int
            EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.username, password: "123456", completion: {
                (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                println(loginInfo)
                if (error == nil) {
                    println("no error")
                    API.userInfo.tokenValid = true
                    self.cancelLock.lock()
                    if self.ifcanceled {
                        self.cancelLock.unlock()
                        self.iflogining = false
                        self.loginButton.enabled = true
                        return
                    }
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var main: UITabBarController = mainStoryboard.instantiateInitialViewController() as UITabBarController
                    
//                    self.presentingViewController!.view.userInteractionEnabled = true
//                    self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                    self.presentViewController(main, animated: true, completion: nil)
                    
                    NSLog("dismiss")
                    self.cancelLock.unlock()
                    self.iflogining = false
                    self.loginButton.enabled = true
                }
                else {/*
                    API.userInfo.tokenValid = false
                    EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.phone, password: "123456", completion: {
                    (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                    println(error)
                    if (error == nil) {
                    API.userInfo.tokenValid = true
                    if self.activity.isAnimating() {
                    self.activity.stopAnimating()
                    }
                    self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {*/
                    println(error.description)
                    //EaseMob.sharedInstance().chatManager.registerNewAccount(API.userInfo.username, password: "123456", error: nil)
                    self.iflogining = false
                    var alert = UIAlertView(title: "提示", message: "对不起，暂时不能登录，请稍候重试", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    //}
                    //}, onQueue: nil)
                }
                }, onQueue: nil)
            //APService.setTags(NSSet(array: [API.userInfo.username]), alias: API.userInfo.username, callbackSelector: "setTags:", target: self)
            
            //loginButton.enabled = true
            //loginButton.userInteractionEnabled = true
            //println("unlock")
            //YoLock.sharedInstance().lock.unlock()

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
