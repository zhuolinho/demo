//
//  ANNViewController.swift
//  demo
//
//  Created by HoJolin on 15/4/6.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ANNViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManger = CLLocationManager()
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBAction func buttonClick(sender: UIButton) {
        locationManger.startUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (array,error) -> Void in
            if array.count > 0 {
                let placemarks = array as [CLPlacemark]
                var placemark: CLPlacemark?
                placemark = placemarks[0]
                println(placemark)
                self.locationLabel.text = placemark?.name
            }
            else {
                self.locationLabel.text = "获取失败"
            }
            
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManger.delegate = self
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 {
            locationManger.requestWhenInUseAuthorization()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        "获取失败"
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
