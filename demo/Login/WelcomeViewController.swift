//
//  WelcomeViewController.swift
//  ActionDemo
//
//  Created by HoJolin on 15/3/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var pageControl1: UIPageControl!
    @IBOutlet weak var scrollView1: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView1.delegate = self
        scrollView1.contentSize = CGSize(width: 320*3, height: 568)
        var aview = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        aview.backgroundColor = UIColor.redColor()
        scrollView1.addSubview(aview)
        var bview = UIView(frame: CGRect(x: 320, y: 0, width: 320, height: 568))
        bview.backgroundColor = UIColor.greenColor()
        scrollView1.addSubview(bview)
        var cview = UIView(frame: CGRect(x: 320*2, y: 0, width: 320, height: 568))
        cview.backgroundColor = UIColor.blueColor()
        scrollView1.addSubview(cview)
//         Do any additional setup after loading the view.
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var curPage = scrollView.contentOffset.x/320
        pageControl1.currentPage = Int(curPage)
        
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
