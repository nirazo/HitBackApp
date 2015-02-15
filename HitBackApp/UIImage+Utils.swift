//
//  UIImage+Utils.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/08.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation

extension UIImage {
    
    // リサイズ
    public func resizedImage(width : CGFloat!, height : CGFloat!) -> UIImage? {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    // 回転
    // degree: 回転させる角度
    public func rotateImage(degree : CGFloat) -> UIImage{
        var imgSize : CGSize = CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(imgSize);
        var context : CGContextRef = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, self.size.width/2, self.size.height/2); // 回転の中心点を移動
        CGContextScaleCTM(context, 1.0, -1.0); // Y軸方向を補正
        var radian : CGFloat  = degree * CGFloat(M_PI) / CGFloat(180)  // 45°回転させたい場合
        CGContextRotateCTM(context, radian);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-self.size.width/2, -self.size.height/2, self.size.width, self.size.height), self.CGImage);
        
        var rotatedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return rotatedImage
    }
}