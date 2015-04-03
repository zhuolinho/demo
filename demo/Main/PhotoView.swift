//
//  PhotoView.swift
//  demo
//
//  Created by HoJolin on 15/4/3.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class PhotoView: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    var url = ""
    var pageIndex = 0
    var touchUp = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if PicDic.picDic[url] == nil {
            photoView.image = UIImage()
        }
        else {
            photoView.image = PicDic.picDic[url]
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        touchUp = true
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        touchUp = false
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if touchUp {
            if (self.presentingViewController != nil) {
                self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                
            }
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
