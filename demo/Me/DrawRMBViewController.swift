//
//  DrawRMBViewController.swift
//  demo
//
//  Created by HoJolin on 15/5/20.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class DrawRMBViewController: UIViewController, APIProtocol {

    let api = API()
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var rmbTF: UITextField!
    @IBAction func drawButtonClick(sender: AnyObject) {
        if rmbTF.text.toInt() == nil || rmbTF.text.toInt() <= 0 {
            let alert = UIAlertView(title: "请输入正确的金额", message: "", delegate: nil, cancelButtonTitle: "确认")
            alert.show()
        }
        else if accountTF.text == "" {
            let alert = UIAlertView(title: "请输入你的支付宝账号", message: "", delegate: nil, cancelButtonTitle: "确认")
            alert.show()
        }
        else {
            api.addWithdrawRequest(rmbTF.text.toInt()!, accountInfo: accountTF.text)
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
        let alert = UIAlertView(title: "提交失败", message: "", delegate: nil, cancelButtonTitle: "确定")
        alert.show()
    }

    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! Int
        if res == 1 {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "提交成功", message: "余额会在五个工作日内到账", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "余额不足", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
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
