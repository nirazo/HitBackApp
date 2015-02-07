//
//  UIImage+Utils.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/08.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation

extension UIImage {
    
    // 指定したUIImageをリサイズ
    public func resizedImage(width : CGFloat!, height : CGFloat!) -> UIImage? {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
}