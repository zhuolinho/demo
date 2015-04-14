//
//  TouchableScroolView.swift
//  demo
//
//  Created by HoJolin on 15/4/3.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class TouchableScroolView: UIScrollView {
    var touchUp = false
    var delegat: TouchableScroolViewDelegate?
    var timer = NSTimer()
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        touchUp = true
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "longPress", userInfo: nil, repeats: false)
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        touchUp = false
        timer.invalidate()
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if touchUp && timer.valid {
            delegat?.click()
            timer.invalidate()
        }
    }
    func longPress()
    {
        delegat?.longPress()
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
