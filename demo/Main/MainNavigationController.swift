//
//  MainNavigationController.swift
//  demo
//
//  Created by HoJolin on 15/4/4.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController, ChatViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = UIColor.grayColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wtfButtonClick(username: String!, nickname: String!, url: String!) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("FriendInfoViewController") as! FriendInfoViewController
        vc.isFriend = true
        vc.nickName = nickname
        vc.userName = username
        if PicDic.picDic[url] != nil {
            vc.avatar = PicDic.picDic[url]
        }
        else {
            vc.avatar = UIImage(named: "DefaultAvatar")
        }
        vc.avatarURL = url
        vc.exten = true
        pushViewController(vc, animated: true)
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
