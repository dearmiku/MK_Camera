//
//  MK_CameraConfigurations.swift
//  MK_Camera
//
//  Created by MBP on 2018/2/22.
//  Copyright © 2018年 MBP. All rights reserved.
//

import Foundation
import AVFoundation

///相机配置信息
public struct MK_CameraConfigurations {

    ///闪光灯模式 默认自动模式
    var flashMode = MK_RespValue<AVCaptureDevice.FlashMode>(AVCaptureDevice.FlashMode.auto)

    ///白平衡模式
    var whiteBalanceMode = MK_RespValue<AVCaptureDevice.WhiteBalanceMode>(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance)

    ///聚焦模式
    var fouceMode = MK_RespValue<AVCaptureDevice.FocusMode>(AVCaptureDevice.FocusMode.autoFocus)

    ///是否点击聚焦
    var isTouchFouce = MK_RespValue<Bool>(true)

    ///镜头方向
    var position = MK_RespValue<AVCaptureDevice.Position>(AVCaptureDevice.Position.front)

    ///拍摄内容填充模式
    var previewLayerMode = MK_RespValue<AVLayerVideoGravity>(AVLayerVideoGravity.resizeAspectFill)
    
}
