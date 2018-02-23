//
//  MK_RespValue.swift
//  MK_Camera
//
//  Created by MBP on 2018/2/22.
//  Copyright © 2018年 MBP. All rights reserved.
//

import Foundation

public class MK_RespValue<V> {
    
    public var value:V {
        didSet{
            for item in valueChangeBlocks {
                item(value)
            }
        }
    }
    private var valueChangeBlocks:[(V)->()] = []

    init( _ initValue:V) {
        value = initValue
    }

    ///注意不要Block对Self不要强引用,避免循环引用
    func subscribe(block:@escaping (V)->()){
        valueChangeBlocks.append(block)
    }

}
