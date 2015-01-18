//
//  HBSingleViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/13.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import UIKit
import SpriteKit

class HBSingleViewController: UIViewController {
    
    override func loadView() {
        var skView : SKView = SKView(frame: UIScreen.mainScreen().bounds)
        self.view = skView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var skView : SKView = self.view as SKView
        skView.showsDrawCount = true;
        skView.showsNodeCount = true;
        skView.showsFPS = true;
        
        var scene : SKScene = HBSinglePlayScene(size: self.view.bounds.size)
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}

