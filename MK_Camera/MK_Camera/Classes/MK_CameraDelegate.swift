//
//  MK_CameraDelegate.swift
//  MK_Camera
//
//  Created by MBP on 2018/2/22.
//  Copyright © 2018年 MBP. All rights reserved.
//

import Foundation

///相机代理协议
@objc public protocol MK_CameraDelegate : NSObjectProtocol {

    ///未获得用户授权
    @objc optional func noAuthorization(view:MK_CameraView)

}
