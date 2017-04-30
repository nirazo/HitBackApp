//
//  HBUtils.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/07.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation

struct HBUtils {
    /*
    乱数を生成するメソッド.
    */
    static func getRandomNumber(Min : Float, Max : Float)->Float {
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (Max - Min) + Min
    }
}
