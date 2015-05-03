//
//  PhotosView.swift
//  demo
//
//  Created by HoJolin on 15/4/3.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class PhotosView: UIViewController, UIScrollViewDelegate,  UIActionSheetDelegate {
    var photosData = [NSDictionary]()
    var startIndex = 0
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mainView: UIScrollView!
    var lock = false
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
        if photosData.count < 2 {
            pageControl.hidden = true
        }
        pageControl.numberOfPages = photosData.count
        pageControl.currentPage = startIndex
        pageControl.enabled = false
        mainView.contentSize = CGSize(width: CGFloat(photosData.count) * view.bounds.width, height: view.bounds.height)
        mainView.contentOffset.x = CGFloat(startIndex) * view.bounds.width
        if photosData.count > 0 {
            for i in 0...photosData.count - 1 {
                let url = photosData[i]["url"] as! String
                var imageView = UIImageView(frame: CGRect(x: CGFloat(i) * view.bounds.width + 10, y: 0, width: view.bounds.width - 20, height: view.bounds.height))
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                if PicDic.picDic[url] == nil {
                    imageView.image = UIImage(named: "noimage2")
                    let remoteUrl = NSURL(string: (API.userInfo.imageHost + url))
                    let request: NSURLRequest = NSURLRequest(URL: remoteUrl!)
                    let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error == nil {
                            var rawImage: UIImage? = UIImage(data: data)
                            let img: UIImage? = rawImage
                            if img != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    PicDic.picDic[url] = img
                                    imageView.image = PicDic.picDic[url]
//                                    self.mainView.addSubview(imageView)
                                })
                            }
                        }
                    })
                }
                else {
                    imageView.image = PicDic.picDic[url]
                }
                mainView.addSubview(imageView)
            }
        }
        else {
            let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: view.bounds.width - 20, height: view.bounds.height))
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.image = UIImage(named: "noimage1")
            mainView.addSubview(imageView)
        }
        let singleTap = UITapGestureRecognizer(target: self, action: "click")
        mainView.addGestureRecognizer(singleTap)
        let longTap = UILongPressGestureRecognizer(target: self, action: "longPress")
        mainView.addGestureRecognizer(longTap)
//        var click = UITapGestureRecognizer(
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var curPage = scrollView.contentOffset.x/view.bounds.width
        pageControl.currentPage = Int(curPage)
    }
    func click() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func longPress() {
        lock = !lock
        if lock {
            var actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.addButtonWithTitle("保存图片")
            actionSheet.addButtonWithTitle("分享图片")
            actionSheet.addButtonWithTitle("取消")
            actionSheet.cancelButtonIndex = 2
            actionSheet.showInView(mainView)
        }
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 && photosData.count > 0 {
            let url = photosData[pageControl.currentPage]["url"] as! String
            if PicDic.picDic[url] != nil {
                UIImageWriteToSavedPhotosAlbum(PicDic.picDic[url], self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
        else if buttonIndex == 1 && photosData.count > 0 {
            let url = photosData[pageControl.currentPage]["url"] as! String
            if PicDic.picDic[url] != nil {
//                RespImageContent(PicDic.picDic[url]!, url)
            }
        }
    }
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            let alert = UIAlertView(title: "保存失败", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
        else {
            let alert = UIAlertView(title: "保存成功", message: "", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
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
