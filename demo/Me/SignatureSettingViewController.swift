//
//  SignatureSettingViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/14.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class SignatureSettingViewController: UIViewController, APIProtocol {

    var api = API()
    var signature = ""
    @IBOutlet weak var signatureTF: UITextField!
    @IBAction func saveButtonClick(sender: UIBarButtonItem) {
        signature = signatureTF.text
        api.setSignature(signature)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        signatureTF.text = API.userInfo.signature
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
        API.userInfo.signature = signature
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
