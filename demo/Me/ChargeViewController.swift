//
//  ChargeViewController.swift
//  demo
//
//  Created by HoJolin on 15/5/13.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ChargeViewController: UIViewController, AlipayRequestConfigDelegate, APIProtocol, UIAlertViewDelegate {

    let alipay = AlipayRequestConfig()
    var fee = ""
    let api = API()
    @IBOutlet weak var moneyTF: UITextField!
    @IBAction func chargeButtonClick(sender: UIButton) {
        moneyTF.resignFirstResponder()
        let charge = (moneyTF.text as NSString).doubleValue
        if charge > 0 {
            alipay.alipayWithPartner(kPartnerID, seller: kSellerAccount, tradeNO: String(format: "%.0f", NSDate.timeIntervalSinceReferenceDate() * 1000), productName: "求监督", productDescription: "充值金币", amount: String(format: "%.2f", charge) , notifyURL: kNotifyURL, itBPay: "30m")
        }
        else {
            let alert = UIAlertView(title: "请输入正确的金额", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        alipay.delegate = self
        api.delegate = self
        // Do any additional setup after loading the view.
    }
    func AlipayRequestBack(result: [NSObject : AnyObject]!) {
        if result["resultStatus"] as! String == "9000" {
            let strRange1 =  result["result"]!.stringValue.rangeOfString("&total_fee=\"")
            let strRange2 =  result["result"]!.stringValue.rangeOfString("\"&notify_url=")
            if strRange1 != nil && strRange2 != nil {
                fee = result["result"]!.stringValue[Range(start: strRange1!.endIndex, end: strRange2!.startIndex)]
                api.addRMB(fee)
            }
        }
        else {
            let alert = UIAlertView(title: "充值失败", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertView(title: "充值失败", message: "", delegate: self, cancelButtonTitle: "重试")
            alert.show()
        })
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        api.addRMB(fee)
    }
    
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        let res = data["result"] as! Int
        if res > 0 {
            dispatch_async(dispatch_get_main_queue(), {
                API.userInfo.rmb = res
                let alert = UIAlertView(title: "充值成功", message: "", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "充值失败", message: "", delegate: self, cancelButtonTitle: "重试")
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
