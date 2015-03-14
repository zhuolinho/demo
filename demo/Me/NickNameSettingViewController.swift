//
//  NickNameSettingViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/14.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class NickNameSettingViewController: UIViewController,APIProtocol {
    var api = API()
    var nickName = ""
    @IBAction func saveButtonclick(sender: UIBarButtonItem) {
        if !nickNameTF.text.isEmpty{
            nickName = nickNameTF.text
            api.setNickname(nickName)
        }
    }
    @IBOutlet weak var nickNameTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        nickNameTF.text = API.userInfo.nickname
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        API.userInfo.nickname = nickName
        self.navigationController?.popViewControllerAnimated(true)
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
