//
//  My2Dcode.swift
//  demo
//
//  Created by HoJolin on 15/4/7.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class My2Dcode: UIViewController {

    @IBOutlet weak var image2Dcode: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        image2Dcode.image = {
            var qrCode = QRCode("我是一个很棒的应用~&&" + String(API.userInfo.id) + "%%" + API.userInfo.username + "##" + API.userInfo.nickname)!
            qrCode.size = self.image2Dcode.bounds.size
            return qrCode.image
            }()
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
