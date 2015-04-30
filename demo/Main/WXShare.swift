//
//  File.swift
//  demo
//
//  Created by HoJolin on 15/4/30.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import Foundation

func RespImageContent(image: UIImage) {
    let message = WXMediaMessage()
    message.setThumbImage(image)
    let resp = SendMessageToWXReq()
    resp.text = "feifeifeo"
    resp.bText = true
    resp.scene = 1
    WXApi.sendReq(resp)
}