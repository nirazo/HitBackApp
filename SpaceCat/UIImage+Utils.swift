//
//  UIImage+Utils.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/08.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    // リサイズ
    public func resize(width : CGFloat!, height : CGFloat!) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // 回転
    // degree: 回転させる角度
    public func rotate(degree : CGFloat) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width, height: self.size.height), false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let radian: CGFloat = (-degree) * CGFloat(Float.pi) / 180.0
        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let rotatedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}
