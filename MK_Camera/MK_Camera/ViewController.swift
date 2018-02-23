//
//  ViewController.swift
//  MK_Camera
//
//  Created by MBP on 2018/2/22.
//  Copyright © 2018年 MBP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = MK_CameraView.init(delegate: self, confi: nil)

        v.frame = CGRect.init(x: 0, y: 100, width: 375, height: 100)
        self.view.addSubview(v)
    }
}
extension ViewController:MK_CameraDelegate{
    func noAuthorization(view: MK_CameraView) {
        print("未授权相机")
    }
}
