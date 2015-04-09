//
//  PhotosView.swift
//  demo
//
//  Created by HoJolin on 15/4/3.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class PhotosView: UIViewController, UIScrollViewDelegate, TouchableScroolViewDelegate, UIActionSheetDelegate {
    var photosData = [NSDictionary]()
    var startIndex = 0
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mainView: TouchableScroolView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
        mainView.delegat = self
        if photosData.count < 2 {
            pageControl.hidden = true
        }
        pageControl.numberOfPages = photosData.count
        pageControl.currentPage = startIndex
        pageControl.enabled = false
        mainView.contentSize = CGSize(width: CGFloat(photosData.count) * view.bounds.width, height: view.bounds.height)
        mainView.contentOffset.x = CGFloat(startIndex) * view.bounds.width
        for i in 0...photosData.count - 1 {
            let url = photosData[i]["url"] as! String
            var imageView = UIImageView(frame: CGRect(x: CGFloat(i) * view.bounds.width + 10, y: 0, width: view.bounds.width - 20, height: view.bounds.height))
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            if PicDic.picDic[url] == nil {
                imageView.image = UIImage()
            }
            else {
                imageView.image = PicDic.picDic[url]
            }
            mainView.addSubview(imageView)
        }
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
        var actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("保存图片")
        actionSheet.addButtonWithTitle("分享图片")
        actionSheet.addButtonWithTitle("取消")
        actionSheet.cancelButtonIndex = 2
        actionSheet.showInView(mainView)
        
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
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
