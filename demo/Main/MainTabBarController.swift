//
//  MainTabBarController.swift
//  demo
//
//  Created by HoJolin on 15/4/4.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, IChatManagerDelegate {

    var buddyRequest = false
    var delegat: ValuePass?
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.orangeColor()
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        let vc = self.viewControllers![2] as! UIViewController
        if UIApplication.sharedApplication().applicationIconBadgeNumber != 0 {
            vc.tabBarItem.badgeValue = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
        }
        // Do any additional setup after loading the view.
    }
    
    func didFinishedReceiveOfflineCmdMessages(offlineCmdMessages: [AnyObject]!) {
        setupUnreadMessageCount()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didUnreadMessagesCountChanged() {
        setupUnreadMessageCount()
    }
    func setupUnreadMessageCount() {
        var conversations = EaseMob.sharedInstance().chatManager.conversations
        var unreadCount: Int = 0
        for item in conversations! {
            let conversation = item as! EMConversation
            unreadCount += Int(conversation.unreadMessagesCount())
        }
        let vc = self.viewControllers![2] as! UIViewController
        if unreadCount > 0 {
            vc.tabBarItem.badgeValue = String(unreadCount)
            if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
                UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCount
            }
        }
        else {
            vc.tabBarItem.badgeValue = nil
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    func didReceiveBuddyRequest(username: String?, message: String?) {
        if username == nil {
            return
        }
        var mess = "请求添加好友"
        if message != nil {
            mess = message!
        }
        var messag = "你有一个好友申请"
        var dic = NSDictionary(dictionary: ["title": username!, "username": username!, "applyMessage": mess, "applyStyle": "0"])
        ApplyViewController.shareController().loadDataSourceFromLocalDB()
        ApplyViewController.shareController().addNewApply(dic as [NSObject : AnyObject])
        var notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.alertBody = messag//[NSString stringWithFormat:@"%@:%@", title, messageStr];
        notification.alertAction = "打开"
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        //发送通知
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            EaseMob.sharedInstance().deviceManager.asyncPlayVibration()
        }
        buddyRequest = true
    }
    func getWeiXinCodeFinishedWithResp(resp: BaseResp) {
        if resp.errCode == 0 {
            let aresp = resp as! SendAuthResp
            getAccessTokenWithCode(aresp.code)
        }
        else {
            delegat?.wxLogin(false)
        }
    }
    func getAccessTokenWithCode(code: NSString) {
        let url = NSURL(string: "https://api.weixin.qq.com/sns/oauth2/access_token?appid=wx81be35fa8a88655e&secret=ce32fd443da71497366f896e5bd6423a&code=\(code)&grant_type=authorization_code")
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let dataStr = NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil)
            let data = dataStr?.dataUsingEncoding(NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue(), {
                if data != nil {
                    let dict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                    if dict["errcode"] == nil {
                        self.getUserInfoWithAccessToken(dict["access_token"] as! NSString, andOpenId: dict["openid"] as! NSString)
                    }
                    else {
                        self.delegat?.wxLogin(false)
                    }
                }
                else {
                    self.delegat?.wxLogin(false)
                }
            })
        })
        
    }
    func getUserInfoWithAccessToken(accessToken: NSString, andOpenId: NSString) {
        let url = NSURL(string: "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(andOpenId)")
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let dataStr = NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil)
            let data = dataStr?.dataUsingEncoding(NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue(), {
                if data != nil {
                    let dict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                    if dict["errcode"] == nil {
                        println(dict)
                        self.delegat?.wxLogin(true)
                    }
                    else {
                        self.delegat?.wxLogin(false)
                    }
                }
                else {
                    self.delegat?.wxLogin(false)
                }
            })
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
