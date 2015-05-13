//
//  UIColorExtension.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/05/09.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import UIKit

extension UIColor {
    class func rgb(#r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    class func MainColor() -> UIColor {
        return UIColor.rgb(r: 24, g: 135, b: 208, alpha: 1.0)
    }
}
