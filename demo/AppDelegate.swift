
//
//  AppDelegate.swift
//  Action
//
//  Created by HoJolin on 15/3/2.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IChatManagerDelegate, IDeviceManagerDelegate, APIProtocol {
    
    var window: UIWindow?
    var checkToken = API()
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        EaseMob.sharedInstance().registerSDKWithAppKey("action#actiontech", apnsCertName: "actionShen")
        EaseMob.sharedInstance().deviceManager.addDelegate(self, onQueue: nil)
        EaseMob.sharedInstance().chatManager.removeDelegate(self)
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        checkToken.delegate = self
        let userPreference: NSDictionary? = (NSUserDefaults.standardUserDefaults().objectForKey("YoUserInfo") as? NSDictionary)
        if userPreference != nil {
            let token: String = userPreference!["token"] as! String
            API.userInfo.token = token
            if !API.userInfo.token.isEmpty {
                checkToken.getMyInfo()
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            let userInfoDic: NSDictionary = NSDictionary(dictionary: ["token": API.userInfo.token])
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        let userNotificationTypes = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        let remoteNotificationTypes = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert
        
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 {
            APService.registerForRemoteNotificationTypes(userNotificationTypes.rawValue, categories: nil)
        }
        else {
            APService.registerForRemoteNotificationTypes(remoteNotificationTypes.rawValue, categories: nil)
        }
        APService.setupWithOption(launchOptions)
//        if application.respondsToSelector("registerForRemoteNotifications:"){
//            application.registerForRemoteNotifications()
//            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//        else {
//            UIApplication.sharedApplication().registerForRemoteNotificationTypes(remoteNotificationTypes)
//        }
//        
//        if launchOptions == nil {
//            EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: NSDictionary(objects: [], forKeys: []))
//        } else {
//            EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//        }

//        EaseMob.sharedInstance().chatManager.enableDeliveryNotification!()
        return true
    }
    func didReceiveMessage(message: EMMessage!) {
        var appState = UIApplication.sharedApplication().applicationState
        if appState == UIApplicationState.Active {
            EaseMob.sharedInstance().deviceManager.asyncPlayVibration()
        }
        else {
            EaseMob.sharedInstance().deviceManager.asyncPlayVibration()
            EaseMob.sharedInstance().deviceManager.asyncPlayNewMessageSound()
            showNotificationWithMessage(message)
        }
    }
    func showNotificationWithMessage(message: EMMessage) {
        var messageBody = message.messageBodies[0] as! IEMMessageBody
        var messageStr = "新消息"
        var notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.alertBody = messageStr//[NSString stringWithFormat:@"%@:%@", title, messageStr];
        notification.alertAction = "打开"
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        //发送通知
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
        
    }
    func didReceiveBuddyRequest(username: String!, message: String!) {
        if username == nil {
            return
        }
        var messag = username + " 添加你喂好友"
        var dic = NSMutableDictionary(dictionary: ["title": username, "username": username, "applyMessage": message, "applyStyle": "0"])
        ApplyViewController.shareController().loadDataSourceFromLocalDB()
        ApplyViewController.shareController().addNewApply(dic as [NSObject : AnyObject])
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        EaseMob.sharedInstance().application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        APService.registerDeviceToken(deviceToken)
    }
//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        EaseMob.sharedInstance().application(application, didFailToRegisterForRemoteNotificationsWithError: error)
//    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        APService.handleRemoteNotification(userInfo)
//        EaseMob.sharedInstance().deviceManager.asyncPlayNewMessageSound()
//        EaseMob.sharedInstance().deviceManager.asyncPlayVibration()
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        APService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
//        EaseMob.sharedInstance().deviceManager.asyncPlayNewMessageSound()
//        EaseMob.sharedInstance().deviceManager.asyncPlayVibration()
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! NSDictionary
        if res.count > 0 {
            API.userInfo.username = res["username"] as! String
            API.userInfo.nickname = res["nickname"] as! String
            API.userInfo.phone = res["phone"] as! String
            API.userInfo.gender = res["gender"] as! String
            API.userInfo.profilePhotoUrl = res["avatar"] as! String
            API.userInfo.signature = res["sign"] as! String
            API.userInfo.id = res["uid"] as! Int
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
                }
                else {
                    API.userInfo.tokenValid = false
                    EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.phone, password: "123456", completion: {
                        (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
                        if (error == nil) {
                            API.userInfo.tokenValid = true
                        }
                        else {
                            EaseMob.sharedInstance().chatManager.registerNewAccount(API.userInfo.username, password: "123456", error: nil)
                        }
                        }, onQueue: nil)
                }
                }, onQueue: nil)
            APService.setTags([API.userInfo.username], alias: API.userInfo.username, callbackSelector: nil, target: self)
        }
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        EaseMob.sharedInstance().applicationWillResignActive(application)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        EaseMob.sharedInstance().applicationDidEnterBackground(application)
        let userInfoDic: NSDictionary = NSDictionary(dictionary: ["token": API.userInfo.token])
        NSUserDefaults.standardUserDefaults().setObject(userInfoDic, forKey: "YoUserInfo")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        EaseMob.sharedInstance().applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        EaseMob.sharedInstance().applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        EaseMob.sharedInstance().applicationWillTerminate(application)
        let userInfoDic: NSDictionary = NSDictionary(dictionary: ["token": API.userInfo.token])
        NSUserDefaults.standardUserDefaults().setObject(userInfoDic, forKey: "YoUserInfo")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
}

