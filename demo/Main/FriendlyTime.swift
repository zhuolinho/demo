//
//  FriendlyTime.swift
//  demo
//
//  Created by HoJolin on 15/4/27.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import Foundation

func friendlyTime(dateTime: String) -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
    dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
    if let date = dateFormatter.dateFromString(dateTime) {
        let delta = NSDate().timeIntervalSinceDate(date)
        
        if (delta <= 0) {
            return "刚刚"
        }
        else if (delta < 60) {
            return "\(Int(delta))秒前"
        }
        else if (delta < 3600) {
            return "\(Int(delta / 60))分钟前"
        }
        else {
            let calendar = NSCalendar.currentCalendar()
            let unitFlags = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
            let comp = calendar.components(unitFlags, fromDate: NSDate())
            let currentYear = String(comp.year)
            let currentDay = String(comp.day)
            
            let comp2 = calendar.components(unitFlags, fromDate: date)
            let year = String(comp2.year)
            let month = String(comp2.month)
            let day = String(comp2.day)
            var hour = String(comp2.hour)
            var minute = String(comp2.minute)
            
            if comp2.hour < 10 {
                hour = "0" + hour
            }
            if comp2.minute < 10 {
                minute = "0" + minute
            }
            
            if currentYear == year {
                if currentDay == day {
                    return "今天 \(hour):\(minute)"
                } else {
                    return "\(month)月\(day)日 \(hour):\(minute)"
                }
            } else {
                return "\(year)年\(month)月\(day)日 \(hour):\(minute)"
            }
        }
    }
    return ""
}