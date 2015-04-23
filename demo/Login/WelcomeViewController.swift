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
        resignButton.layer.cornerRadius = 5
        resignButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        scrollView1.delegate = self
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        scrollView1.contentSize = CGSize(width: width*4, height: 0)
        var aview = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        aview.image = UIImage(named: "P1")
        scrollView1.addSubview(aview)
        var bview = UIImageView(frame: CGRect(x: width, y: 0, width: width, height: height))
        bview.image = UIImage(named: "P2")
        scrollView1.addSubview(bview)
        var cview = UIImageView(frame: CGRect(x: width*2, y: 0, width: width, height: height))
        cview.image = UIImage(named: "P3")
        scrollView1.addSubview(cview)
        var dview = UIImageView(frame: CGRect(x: width*3, y: 0, width: width, height: height))
        dview.image = UIImage(named: "P4")
        scrollView1.addSubview(dview)
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
