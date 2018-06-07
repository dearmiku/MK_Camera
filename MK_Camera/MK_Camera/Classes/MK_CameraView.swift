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
    public init(frame:CGRect,confi:MK_CameraConfigurations?,delegate:MK_CameraDelegate?) {
        self.confi = confi == nil ? MK_CameraConfigurations() : confi!
        self.delegate = delegate
        super.init(frame: frame)
        if MK_Detector.checkIsMachine(){
            self.setupCamera()
        }
    }
    
    public convenience init(delegate:MK_CameraDelegate? = nil,confi:MK_CameraConfigurations? = nil){
        self.init(frame: CGRect.zero, confi: nil, delegate: delegate)
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
    
    //MARK:-代理
    public weak var delegate:MK_CameraDelegate?
    
    
    lazy var detector = MK_Detector.check()
    
    
    ///初始化相机
    func setupCamera(){
        ///未授权
        guard !MK_Detector.noAuthorization.isExist(num: detector) else{
            delegate?.noAuthorization?(view: self)
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
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(focusGesture(gesture:)))
        self.addGestureRecognizer(gesture)
        
        ///是否点击对焦
        confi.isTouchFouce.subscribe { (res) in
            gesture.isEnabled = res
        }
        
        ///闪光灯
        confi.flashMode.subscribe { [weak self] (mode) in
            self?.deviceLockRunBlock {
                if self!.device.isFlashModeSupported(mode){
                    self!.device.flashMode = mode
                }
            }
        }
        ///白平衡
        confi.whiteBalanceMode.subscribe { [weak self] (mode) in
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
        ///手动调焦 
        confi.focalLength.subscribe {[weak self] (po) in
            guard let length = po else { return }
            if self?.confi.fouceMode.value != AVCaptureDevice.FocusMode.locked{
                self?.confi.fouceMode.value = .locked
            }
            self?.deviceLockRunBlock {
                self?.device.setFocusModeLocked(lensPosition: length, completionHandler: nil)
            }
        }
        ///曝光模式
        confi.exportMode.subscribe {[weak self] (mode) in
            self?.deviceLockRunBlock {
                self?.device.exposureMode = mode
            }
        }
        ///手动曝光值
        confi.exposureValue.subscribe { (po) in
            guard let num = po else { return }
            if self.confi.exportMode.value != AVCaptureDevice.ExposureMode.custom{
                self.confi.exportMode.value = AVCaptureDevice.ExposureMode.custom
            }
            self.device.setExposureTargetBias(num, completionHandler: nil)
        }
        ///曝光时间
        confi.exposureTime.subscribe {[weak self] (po) in
            guard let num = po else { return }
            if self?.confi.exportMode.value != AVCaptureDevice.ExposureMode.custom{
                self?.confi.exportMode.value = AVCaptureDevice.ExposureMode.custom
            }
            let time = CMTime.init(seconds: num, preferredTimescale: 1)
            self?.device.setExposureModeCustom(duration: time, iso: self!.device.iso, completionHandler: nil)
        }
        ///ISO
        confi.iso.subscribe {[weak self] (po) in
            guard let num = po else { return }
            if self?.confi.exportMode.value != AVCaptureDevice.ExposureMode.custom{
                self?.confi.exportMode.value = AVCaptureDevice.ExposureMode.custom
            }
            self?.device.setExposureModeCustom(duration: self!.device.exposureDuration, iso: num, completionHandler: nil)
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
        self.session.startRunning()
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
    //进行点击屏幕对焦
    @objc func focusGesture(gesture:UITapGestureRecognizer){
        let point = gesture.location(in: gesture.view)
        let size = self.bounds.size
        let focusPoint = CGPoint.init(x: point.y/size.height, y: 1-point.x/size.width)
        do{
            try self.device.lockForConfiguration()
            if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose) {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
            delegate?.clickFocus?(view: self, point: point)
        }catch{}
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
        if MK_Detector.checkIsMachine(){
            self.session.stopRunning()
        }
    }
    ///恢复拍摄
    public func startRuning(){
        if MK_Detector.checkIsMachine(){
            self.session.startRunning()
        }
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

