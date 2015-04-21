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
            EaseMob.sharedInstance().chatManager.logoffWithError(nil)
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
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
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
            let res = data["result"] as! NSDictionary
            if res["token"] as! NSString == "wrong" {
                var alert = UIAlertView(title: "手机号或密码有误", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                //loginButton.userInteractionEnabled = true
                //println("unlock")
                //YoLock.sharedInstance().lock.unlock()
                iflogining = false
                loginButton.enabled = true
            }
            else {
                API.userInfo.token = res["token"] as! String
                let userInfoDic: NSDictionary = NSDictionary(dictionary: ["token": API.userInfo.token])
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
                iflogining = false
                loginButton.enabled = true
                return
            }
            cancelLock.unlock()
            let res = data["result"] as! NSDictionary
            API.userInfo.username = res["username"] as! String
            API.userInfo.nickname = res["nickname"] as! String
            API.userInfo.phone = res["phone"] as! String
            API.userInfo.gender = res["gender"] as! String
            API.userInfo.rmb = res["rmb"] as! Int
            API.userInfo.id = res["uid"] as! Int
            API.userInfo.profilePhotoUrl = res["avatar"] as! String
            API.userInfo.signature = res["sign"] as! String
            API.userInfo.phone = res["phone"] as! String
            if !API.userInfo.profilePhotoUrl.isEmpty {
                let url = NSURL(string: (API.userInfo.imageHost + API.userInfo.profilePhotoUrl))
                let request: NSURLRequest = NSURLRequest(URL: url!)
                let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        let img: UIImage? = UIImage(data: data)
                        let avatar: UIImage? = img
                        if avatar != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                PicDic.picDic[API.userInfo.profilePhotoUrl] = avatar
                                API.userInfo.profilePhoto = avatar!
                            })
                        }
                    }
                })
            }
            EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.username, password: "123456", completion: {
                (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                if (error == nil) {
                    API.userInfo.tokenValid = true
                    self.cancelLock.lock()
                    if self.ifcanceled {
                        self.cancelLock.unlock()
                        self.iflogining = false
                        self.loginButton.enabled = true
                        return
                    }
                    self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                    self.cancelLock.unlock()
                    self.iflogining = false
                    self.loginButton.enabled = true
                }
                else {
                    //EaseMob.sharedInstance().chatManager.registerNewAccount(API.userInfo.username, password: "123456", error: nil)
                    self.iflogining = false
                    self.loginButton.enabled = true
                    var alert = UIAlertView(title: "提示", message: "对不起，暂时不能登录，请稍候重试", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }, onQueue: nil)
            APService.setTags([API.userInfo.username], alias: API.userInfo.username, callbackSelector: "setTags:", target: self)
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
