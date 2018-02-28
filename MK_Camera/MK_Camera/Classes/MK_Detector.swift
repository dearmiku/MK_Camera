//
//  MK_Detector.swift
//  MK_Camera
//
//  Created by MBP on 2018/2/22.
//  Copyright © 2018年 MBP. All rights reserved.
//

import Foundation
import Photos

///权限与设备检测
public enum MK_Detector : Int {

    ///未授权
    case noAuthorization =  0b0001
    ///相机无法使用
    case cameraDamaged =    0b0010
    ///前置相机无法使用
    case fontCameraDamage = 0b0100
    ///后置相机无法使用
    case rearCameraDamage = 0b1000


    ///检测
    static func check()->Int{
        var res = 0b0000
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .denied {
            res = res | MK_Detector.noAuthorization.rawValue
        }
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            res = res | MK_Detector.cameraDamaged.rawValue
        }
        if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front){
            res = res | MK_Detector.fontCameraDamage.rawValue
        }
        if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear){
            res = res | MK_Detector.rearCameraDamage.rawValue
        }
        return res
    }

    ///检查是否为真机
    static func checkIsMachine()->Bool{
        return AVCaptureDevice.default(for: AVMediaType.video) != nil
    }


    ///当前枚举是否在检测结果中存在
    func isExist(num:Int)->Bool{
        return num & self.rawValue == self.rawValue
    }
}


