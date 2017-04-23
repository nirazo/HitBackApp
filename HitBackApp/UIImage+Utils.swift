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
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    // 回転
    // degree: 回転させる角度
    public func rotateImage(degree : CGFloat) -> UIImage{
        let imgSize : CGSize = CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(imgSize)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width/2, y: self.size.height/2); // 回転の中心点を移動
        context.scaleBy(x: 1.0, y: -1.0); // Y軸方向を補正
        let radian : CGFloat  = degree * CGFloat(Float.pi) / CGFloat(180)  // 45°回転させたい場合
        context.rotate(by: radian)
        
        context.draw(UIGraphicsGetCurrentContext() as! CGImage, in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height), byTiling: (self.cgImage != nil))
        
        let rotatedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return rotatedImage
    }
}
