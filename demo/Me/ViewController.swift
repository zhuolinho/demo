//
//  ViewController.swift
//  2Dcode
//
//  Created by shenyang on 15/3/15.
//  Copyright (c) 2015年 shenyang. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var lock = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        messageView.frame = CGRectMake(0, height*6/7, width, height/7)
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        
        if (error != nil) {
            // If any error occurs, simply log the description of it and don't continue any more.
            println("\(error?.localizedDescription)")
            return
        }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as! AVCaptureInput)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // Start video capture.
        captureSession?.startRunning()
        // Move the message label to the top view
        view.bringSubviewToFront(messageView)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        lock = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?

    @IBOutlet weak var messageView: UIView!

    @IBOutlet weak var messageLabel: UILabel!
    
    func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection
        connection: AVCaptureConnection!) {
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects == nil || metadataObjects.count == 0 {
                qrCodeFrameView?.frame = CGRectZero
                messageLabel.text = "No QR code is detected"
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject =
                videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj
                    as AVMetadataMachineReadableCodeObject) as!
                AVMetadataMachineReadableCodeObject
                qrCodeFrameView?.frame = barCodeObject.bounds;
                
                if metadataObj.stringValue != nil && !lock{
                    messageLabel.text = metadataObj.stringValue
                    let strRange1 =  metadataObj.stringValue.rangeOfString("%%")
                    let strRange2 =  metadataObj.stringValue.rangeOfString("##")
                    if strRange1 != nil && strRange2 != nil {
                        self.lock = true
                        let username = metadataObj.stringValue[Range(start: strRange1!.endIndex, end: strRange2!.startIndex)]
                        var info = ["username": username, "nickname": "*", "avatarURL": ""]
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            let requestAvatarUrl = NSURL(string: "\(API.userInfo.host)getAvatarAndNicknameFromUid.action?userstr=\(username)") // No such API !!!!!!!!!!!!!
                            let request: NSURLRequest = NSURLRequest(URL: requestAvatarUrl!)
                            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                if error == nil {
                                    var jsonRaw: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                                    if (jsonRaw != nil) {
                                        var jsonResult = jsonRaw as! NSDictionary
                                        if jsonResult.count > 0 {
                                            let result = jsonResult["result"] as! NSDictionary
                                            let urlWithComma = result["avatar"] as! String
                                            let nicknameWithComma = result["nickname"] as! String
                                            let url = urlWithComma.componentsSeparatedByString(",")[0]
                                            let nickname = nicknameWithComma.componentsSeparatedByString(",")[0]
                                            var avatar = UIImage(named: "DefaultAvatar")
                                            if PicDic.picDic[url] == nil {
                                                let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                                                let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                                                let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                                                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                                    if error == nil {
                                                        var rawImage: UIImage? = UIImage(data: data)
                                                        let img: UIImage? = rawImage
                                                        if img != nil {
                                                            dispatch_async(dispatch_get_main_queue(), {
                                                                avatar = img
                                                                PicDic.picDic[url] = img
                                                            })
                                                        }
                                                    }
                                                })
                                            }
                                            else {
                                                avatar = PicDic.picDic[url]
                                            }
                                            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("FriendInfoViewController") as! FriendInfoViewController
                                            vc.nickName = nickname
                                            vc.userName = username
                                            vc.avatar = avatar
                                            vc.avatarURL = url
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }
                                }
                            })
                        })
                    }
                }
            }
    }
}

