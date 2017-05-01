//
//  Alert.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/21.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit

@objc protocol RegisterAlertDelegate {
    @objc optional func buttonTapped(tag: Int)
}

// アラートメソッド
@available(iOS 8.0, *)
class Alert {
    var delegate : RegisterAlertDelegate!
    
    init() {
    }
    
    init(delegate: RegisterAlertDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(viewController: UIViewController, title: String = "エラー", buttonTitle: String = "OK", message: String, tag: Int = 0) {
            var alert: UIAlertController?
            alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let afterAction = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default) {
                action in
                if self.delegate != nil {
                    self.delegate.buttonTapped!(tag: tag)
                }
            }
            alert!.addAction(afterAction)
            viewController.present(alert!, animated: true, completion: nil)
    }
    
}
