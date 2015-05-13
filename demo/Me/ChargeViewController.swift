//
//  ChargeViewController.swift
//  demo
//
//  Created by HoJolin on 15/5/13.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class ChargeViewController: UIViewController {

    @IBOutlet weak var moneyTF: UITextField!
    @IBAction func chargeButtonClick(sender: UIButton) {
        let charge = (moneyTF.text as NSString).doubleValue
        if charge > 0 {
            let order = Order()
            order.partner = "2088911361045482"
            order.seller = "qiujiandu2016@163.com"
            order.tradeNO = "39375890745028750417"
            order.productName = "马云"
            order.productDescription = "吃翔吧"
            order.amount = String(format: "%.2f", charge)
            let appScheme = "integratedAlipay"
        }
        else {
            let alert = UIAlertView(title: "请输入正确的金额", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
