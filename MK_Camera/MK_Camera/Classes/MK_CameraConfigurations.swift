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
    public var flashMode = MK_RespValue<AVCaptureDevice.FlashMode>(AVCaptureDevice.FlashMode.auto)

    ///白平衡模式
    public var whiteBalanceMode = MK_RespValue<AVCaptureDevice.WhiteBalanceMode>(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance)

    ///聚焦模式
    public var fouceMode = MK_RespValue<AVCaptureDevice.FocusMode>(AVCaptureDevice.FocusMode.continuousAutoFocus)
    ///是否点击聚焦
    public var isTouchFouce = MK_RespValue<Bool>(true)
    ///手动调焦(默认关闭,当设置时将将关闭自动调焦,根据数值锁定焦距,值范围 0~1 从进到远)
    public var focalLength = MK_RespValue<Float?>(nil)

    ///曝光模式
    public var exportMode = MK_RespValue<AVCaptureDevice.ExposureMode>(AVCaptureDevice.ExposureMode.continuousAutoExposure)
    ///手动设置曝光值(注意取值范围)
    public var exposureValue = MK_RespValue<Float?>(nil)

    ///手动设置曝光时间(注意取值范围)
    public var exposureTime =  MK_RespValue<Double?>(nil)
    ///感光度(注意取值范围)
    public var iso = MK_RespValue<Float?>(nil)
    ///镜头方向
    public var position = MK_RespValue<AVCaptureDevice.Position>(AVCaptureDevice.Position.back)

    ///拍摄内容填充模式
    public var previewLayerMode = MK_RespValue<AVLayerVideoGravity>(AVLayerVideoGravity.resizeAspectFill)
    
}

public extension MK_CameraView {

    ///最大曝光值
    public var maxExposureValue: Float{
        get{
            return device.maxExposureTargetBias
        }
    }
    ///最小曝光值
    public var minExposureValue:Float{
        get{
            return device.minExposureTargetBias
        }
    }

    ///最大曝光时间
    public var maxExposureTime:Double{
        get{
            return self.device.activeFormat.maxExposureDuration.seconds / Double(self.device.activeFormat.maxExposureDuration.timescale)
        }
    }
    ///最小曝光时间
    public var minExposureTime:Double{
        get{
            return self.device.activeFormat.minExposureDuration.seconds / Double(self.device.activeFormat.minExposureDuration.timescale)
        }
    }

    ///最大感光值
    public var maxISO:Float{
        get{
            return self.device.activeFormat.maxISO
        }
    }
    ///最小感光值
    public var minISO:Float{
        get{
            return self.device.activeFormat.minISO
        }
    }
}

