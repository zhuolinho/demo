//
//  ChangePWDViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/27.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ChangePWDViewController: UIViewController, APIProtocol {

    let api = API()
    
    @IBOutlet weak var comferTF: UITextField!
    @IBOutlet weak var newPwdFT: UITextField!
    @IBOutlet weak var oldPwdTF: UITextField!
    @IBAction func viewTap(sender: AnyObject) {
        comferTF.resignFirstResponder()
        newPwdFT.resignFirstResponder()
        oldPwdTF.resignFirstResponder()
    }
    @IBAction func commitButtonClick(sender: UIBarButtonItem) {
        if count(comferTF.text) < 6 || count(newPwdFT.text) < 6 || count(oldPwdTF.text) < 6 {
            var alert = UIAlertView(title: "密码不能少于6位", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else {
            if comferTF.text == newPwdFT.text {
                api.setPassword(newPass: newPwdFT.text, oldPass: oldPwdTF.text)
            }
            else {
                var alert = UIAlertView(title: "两次输入不一致", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        
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
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! Int
        if res == 1 {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "修改成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        else if res == -1 {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "密码错误", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertView(title: "修改失败", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
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
