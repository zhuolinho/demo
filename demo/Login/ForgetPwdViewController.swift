//
//  ForgetPwdViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ForgetPwdViewController: UIViewController, APIProtocol {

    let api = API()
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBAction func touchDown(sender: AnyObject) {
        phoneTextField.resignFirstResponder()
    }
    @IBOutlet weak var findButton: UIButton!
    
    @IBAction func findButtonClick(sender: UIButton) {
        if phoneTextField.text == "" {
            let alert = UIAlertView(title: "请输入手机号", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
        else {
            findButton.enabled = false
            api.findPassword(phoneTextField.text)
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

    func didReceiveAPIErrorOf(api: API, errno: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertView(title: "找回失败", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            self.findButton.enabled = true
        })
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if data["result"] as! Int == 1 {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "新密码已发送", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "找回失败", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                self.findButton.enabled = true
            })
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
