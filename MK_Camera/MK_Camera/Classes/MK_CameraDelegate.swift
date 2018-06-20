//
//  MK_CameraDelegate.swift
//  MK_Camera
//
//  Created by MBP on 2018/2/22.
//  Copyright © 2018年 MBP. All rights reserved.
//

import UIKit

///相机代理协议
@objc public protocol MK_CameraDelegate : NSObjectProtocol {

    ///未获得用户授权
    @objc optional func noAuthorization(view:MK_CameraView)

    ///点击聚焦点回调
    @objc optional func clickFocus(view:MK_CameraView,point:CGPoint)

    ///通过相机授权/开始启动相机 时回调方法
    @objc optional func beginSetUpCamera(view:MK_CameraView)

}
