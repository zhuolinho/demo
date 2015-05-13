//
//  MyRMBViewController.swift
//  demo
//
//  Created by HoJolin on 15/5/13.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class MyRMBViewController: UIViewController {

    @IBOutlet weak var rmbLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        rmbLabel.text = String(API.userInfo.rmb)
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
