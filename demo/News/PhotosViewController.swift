//
//  PhotosViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/2.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class PhotosViewController: UIPageViewController, UIPageViewControllerDataSource {
    var photosData = [NSDictionary]()
    var startIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        var pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.backgroundColor = UIColor.whiteColor()
        pageControl.numberOfPages = photosData.count
        pageControl.currentPage = startIndex
        dataSource = self
        let startVC = viewControllerAtIndex(startIndex, storyboard: self.storyboard!)!
        setViewControllers([startVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> PhotoView? {
        if (photosData.count == 0) || (index >= photosData.count) {
            return nil
        }
        var dataViewController: PhotoView = storyboard.instantiateViewControllerWithIdentifier("PhotoView") as PhotoView
        dataViewController.url = photosData[index]["url"] as String
        dataViewController.pageIndex = index
        return dataViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let presentVC = viewController as PhotoView
        if presentVC.pageIndex == photosData.count - 1 {
            return nil
        }
        else {
            return viewControllerAtIndex(presentVC.pageIndex + 1, storyboard: self.storyboard!)
        }
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let presentVC = viewController as PhotoView
        if presentVC.pageIndex == 0 {
            return nil
        }
        else {
            return viewControllerAtIndex(presentVC.pageIndex - 1, storyboard: self.storyboard!)
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
