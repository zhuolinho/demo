//
//  ResignPhoneViewController.swift
//  demo
//
//  Created by HoJolin on 15/3/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//
enum RegistrationStep: Int {
    case SendAuthCode = 0
    case CheckAuthCode
    case SetUpAccount
    case RefreshUserInfo
    case Login
}
import UIKit

class ResignPhoneViewController: UIViewController, APIProtocol {
    
    var sendCodeApi = API()
    var checkCodeApi = API()
    var controllerState = RegistrationStep.SendAuthCode
    var phone:String?
    var code :String?
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    @IBAction func codeButtonClick(sender: UIButton) {
        if !phoneTextField.text.isEmpty {
            sendCodeApi.sendAuthCode(phoneNumber: phoneTextField.text)
        }
        else {
            var alert = UIAlertView(title: "请输入手机号", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    @IBAction func codeEditingDidEnd(sender: UITextField) {
        if phone == nil {
            phone = phoneTextField.text
        }
        checkCodeApi.checkAuthCode(phoneNumber: phone! , authCode: sender.text)
    }
    @IBAction func touchDown1(sender: UIControl) {
        codeTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
    }
    func didReceiveAPIErrorOf(api: API, errno: Int) {
        NSLog("\(errno)")
    }
    func didReceiveAPIResponseOf(api: API, data: NSDictionary) {
        if api === sendCodeApi {
            var result = data["result"] as! NSString
            if result == "wrong" {
                var alert = UIAlertView(title: "发送失败", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            else if result == "repeated" {
                var alert = UIAlertView(title: "手机号重复", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            else {
                phone = phoneTextField.text
                phoneTextField.userInteractionEnabled = false
                codeButton.enabled = false
                controllerState = RegistrationStep.CheckAuthCode
            }
        }
        else {
            var result = data["result"] as! Int
            if result == 1 {
                nextButton.enabled = true
                code = codeTextField.text
                codeTextField.userInteractionEnabled = false
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        sendCodeApi.delegate = self
        checkCodeApi.delegate = self
        nextButton.setTitle("请验证手机号", forState: UIControlState.Disabled)
        nextButton.enabled  = false
        controllerState = RegistrationStep.SendAuthCode
        codeButton.setTitle("已发送", forState: UIControlState.Disabled)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var dest = segue.destinationViewController as? ResignAccountViewController {
            dest.phone = phone
            dest.code = code
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
