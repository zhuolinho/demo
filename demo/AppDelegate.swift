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
        if launchOptions == nil {
            EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: NSDictionary(objects: [], forKeys: []))
        } else {
            EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        EaseMob.sharedInstance().deviceManager.addDelegate(self, onQueue: nil)
        EaseMob.sharedInstance().chatManager.removeDelegate(self)
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        checkToken.delegate = self
        let userPreference: NSDictionary? = (NSUserDefaults.standardUserDefaults().objectForKey("YoUserInfo") as? NSDictionary)
        if userPreference != nil {
            let token: String = userPreference!["token"] as String
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
        return true
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as NSDictionary
        if res.count > 0 {
            API.userInfo.username = res["username"] as NSString
            API.userInfo.nickname = res["nickname"] as NSString
            API.userInfo.phone = res["phone"] as NSString
            API.userInfo.gender = res["gender"] as NSString
            API.userInfo.profilePhotoUrl = res["avatar"] as String
            EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.username, password: "123456", completion: {
                (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
//                println(error)
                if (error == nil) {
                    API.userInfo.tokenValid = true
                }
                else {
                    API.userInfo.tokenValid = false
                    EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(API.userInfo.phone, password: "123456", completion: {
                        (loginInfo: [NSObject : AnyObject]!, error: EMError!) -> Void in
//                        println(error)
                        if (error == nil) {
                            API.userInfo.tokenValid = true
                        }
                        else {
                            EaseMob.sharedInstance().chatManager.registerNewAccount(API.userInfo.username, password: "123456", error: nil)
                        }
                        }, onQueue: nil)
                }
                }, onQueue: nil)
            APService.setTags(NSSet(array: [API.userInfo.username]), alias: API.userInfo.username, callbackSelector: nil, target: self)
//            println(API.userInfo.username)
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

