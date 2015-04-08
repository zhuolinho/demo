//
//  DeletePicViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/8.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class DeletePicViewController: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageview.image = image
        // Do any additional setup after loading the view.
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
