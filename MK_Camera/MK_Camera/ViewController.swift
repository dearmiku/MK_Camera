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
        
        let v = MK_CameraView.init(nil)
        v.frame = CGRect.init(x: 0, y: 100, width: 375, height: 100)
        self.view.addSubview(v)
    }
}

