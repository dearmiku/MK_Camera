//
//  MK_CameraView.swift
//  MK_Camera
//
//  Created by MBP on 2018/2/22.
//  Copyright © 2018年 MBP. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

///自定义相机视图
public class MK_CameraView : UIView {

    //MARK:- 初始化方法
    public init(frame:CGRect,confi:MK_CameraConfigurations?) {
        self.confi = confi == nil ? MK_CameraConfigurations() : confi!
        super.init(frame: frame)
        self.setupCamera()
    }
    public convenience init(_ confi:MK_CameraConfigurations?){
        self.init(frame: CGRect.zero, confi: confi)
    }
    public convenience init(){
        self.init(nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    //MARK:-相机基础属性
    lazy var session = AVCaptureSession()

    lazy var device:AVCaptureDevice = {
        guard let res = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("can't get AVCaptureDevice")
        }
        return res
    }()

    lazy var ImageOutput = AVCaptureStillImageOutput()

    lazy var input:AVCaptureDeviceInput = {
        guard let res = try? AVCaptureDeviceInput.init(device: device) else{
            fatalError("can't get AVCaptureDeviceInput")
        }
        return res
    }()

    lazy var previewLayer = { () -> AVCaptureVideoPreviewLayer in
        let res = AVCaptureVideoPreviewLayer.init(session: session)
        res.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.addSublayer(res)
        return res
    }()

    //MARK:-相机配置信息
    public var confi:MK_CameraConfigurations


    lazy var detector = MK_Detector.check()


    ///初始化相机
    func setupCamera(){
        ///未授权
        guard !MK_Detector.noAuthorization.isExist(num: detector) else{
            return
        }

        if self.session.canSetSessionPreset(AVCaptureSession.Preset.photo){
            self.session.sessionPreset = AVCaptureSession.Preset.photo
        }
        if self.session.canAddInput(self.input){
            self.session.addInput(self.input)
        }
        if self.session.canAddOutput(self.ImageOutput){
            self.session.addOutput(self.ImageOutput)
        }
        self.session.startRunning()

        ///闪光灯
        confi.flashMode.subscribe { [weak self] (mode) in
            self?.deviceLockRunBlock {
                if self!.device.isFlashModeSupported(mode){
                    self!.device.flashMode = mode
                }
            }
        }
        ///白平衡
        confi.whiteBalanceMode.subscribe { [weak self](mode) in
            self?.deviceLockRunBlock {
                if self!.device.isWhiteBalanceModeSupported(mode){
                    self!.device.whiteBalanceMode = mode
                }
            }
        }
        ///聚焦模式
        confi.fouceMode.subscribe {[weak self] (mode) in
            self?.deviceLockRunBlock {
                self?.device.focusMode = mode
            }
        }

        ///镜头朝向
        confi.position.subscribe {[weak self] (position) in
            guard let weakSelf = self else {
                return
            }
            let cameraCount = AVCaptureDevice.devices(for: AVMediaType.video).count
            if cameraCount > 1{
                var newCamera:AVCaptureDevice?
                var newInput:AVCaptureDeviceInput

                newCamera = weakSelf.cameraWithPosition(position: position)

                if newCamera != nil {
                    do{
                        newInput = try AVCaptureDeviceInput.init(device: newCamera!)
                        weakSelf.session.beginConfiguration()
                        weakSelf.session.removeInput(weakSelf.input)
                        if weakSelf.session.canAddInput(newInput){
                            weakSelf.session.addInput(newInput)
                            weakSelf.input = newInput
                        }else{
                            //切换失败
                            weakSelf.session.addInput(weakSelf.input)
                        }
                        weakSelf.session.commitConfiguration()
                        weakSelf.session.startRunning()

                    }catch{

                    }
                    //获取新输入设备失败
                }
            }
        }

    }
    //在转换摄像头时 获取对应的Device
    func cameraWithPosition(position:AVCaptureDevice.Position)->AVCaptureDevice?{
        //后置摄像头不可用
        if position == .back && MK_Detector.rearCameraDamage.isExist(num: detector){
            return nil
        }
        //前置摄像头不可用
        if position == .front && MK_Detector.fontCameraDamage.isExist(num: detector) {
            return nil
        }
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for item in devices {
            if item.position == position{
                return item
            }
        }
        return nil
    }

    public override var frame: CGRect{
        didSet{
            previewLayer.frame = self.bounds
        }
    }



    ///device锁定处理Block
    func deviceLockRunBlock(_ block:()->()){
        do{
            try self.device.lockForConfiguration()
            block()
            self.device.unlockForConfiguration()
        }catch{}

    }
}

///对外扩展方法
public extension MK_CameraView {

    ///暂停拍摄
    public func stopRunning(){
        self.session.stopRunning()
    }
    ///恢复拍摄
    public func startRuning(){
        self.session.stopRunning()
    }
    ///拍摄
    public func shoot(backBlock:@escaping (UIImage?)->()){
        let videoConnection = self.ImageOutput.connection(with: AVMediaType.video)
        if videoConnection == nil{
            backBlock(nil)
            return
        }
        self.ImageOutput.captureStillImageAsynchronously(from: videoConnection!, completionHandler: { (buffer, error) in
            guard let buf = buffer else {
                backBlock(nil)
                return
            }
            let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buf)
            guard let imageData = data else {
                backBlock(nil)
                return
            }
            let image = UIImage.init(data: imageData)
            backBlock(image)
        })
    }
}

