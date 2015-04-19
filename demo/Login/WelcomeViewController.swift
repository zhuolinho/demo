//
//  WelcomeViewController.swift
//  ActionDemo
//
//  Created by HoJolin on 15/3/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var resignButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var pageControl1: UIPageControl!
    @IBOutlet weak var scrollView1: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        resignButton.layer.cornerRadius = 10
        resignButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        scrollView1.delegate = self
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        scrollView1.contentSize = CGSize(width: width*3, height: 0)
        var bview = UIView(frame: CGRect(x: width, y: 0, width: width, height: height))
        bview.backgroundColor = UIColor.greenColor()
        scrollView1.addSubview(bview)
        var aview = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        aview.backgroundColor = UIColor.redColor()
        scrollView1.addSubview(aview)
        var cview = UIView(frame: CGRect(x: width*2, y: 0, width: width, height: height))
        cview.backgroundColor = UIColor.blueColor()
        scrollView1.addSubview(cview)
        pageControl1.enabled = false
//         Do any additional setup after loading the view.
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var curPage = scrollView.contentOffset.x/view.bounds.width
        pageControl1.currentPage = Int(curPage)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
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
