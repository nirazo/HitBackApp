//
//  Alert.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/21.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation


@objc protocol RegisterAlertDelegate {
    optional func buttonTapped(tag: Int)
}

// iOS8以前とiOS8以降両対応アラートメソッド
class Alert {
    var delegate : RegisterAlertDelegate!
    
    init() {
    }
    
    init(delegate: RegisterAlertDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(viewController: UIViewController, title: String = "エラー", buttonTitle: String = "OK", message: String, tag: Int = 0) {
        if ( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ) {
            // iOS 8 ~
            println("UIAlertController can be instantiated")
            var alert: UIAlertController?
            alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let afterAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default) {
                action in
                if self.delegate != nil {
                    self.delegate.buttonTapped!(tag)
                }
            }
            alert!.addAction(afterAction)
            viewController.presentViewController(alert!, animated: true, completion: nil)
        } else {
            // ~ iOS7
            println("UIAlertController can not be instantiated")
            var alert: UIAlertView = UIAlertView()
            alert.delegate = viewController
            alert.title = title
            alert.message = message
            alert.tag = tag
            alert.addButtonWithTitle("閉じる")
            alert.show()
        }
    }
    
}
