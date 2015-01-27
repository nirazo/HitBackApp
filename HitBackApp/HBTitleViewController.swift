//
//  HBTitleViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/12.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class HBTitleViewController: UIViewController {
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var singleStart : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 180, 40))
        singleStart.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) - singleStart.frame.size.height)
        var versusStart : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 180, 40))
        versusStart.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame))
        singleStart.setTitle("守れ！宇宙ねこ", forState: .Normal)
        versusStart.setTitle("対戦モード", forState: .Normal)
        singleStart.addTarget(self, action: "singleStartTapped:", forControlEvents:.TouchUpInside)
        versusStart.addTarget(self, action: "versusStartTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(singleStart)
        //self.view.addSubview(versusStart)
    }
    
    func singleStartTapped(sender: AnyObject?) {
        var vc : HBSingleViewController = HBSingleViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func versusStartTapped(sender: AnyObject?) {
        var vc : HBVersusViewController = HBVersusViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func dismissGameViewControllers() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}