//
//  BBGameOverScene.swift
//  BlockBreaker
//
//  Created by Kenzo on 2015/01/08.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBGameOverScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
        var titleLabel : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue")
        titleLabel.text = "Game Over..."
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        titleLabel.fontSize = 40.0
        self.addChild(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        var scene : SKScene = HBVersusPlayScene(size: self.size)
//        var transition : SKTransition = SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 1.0)
//        self.view?.presentScene(scene, transition: transition)
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self.view!.window!.rootViewController!, selector: "dismissGameViewControllers", userInfo: nil, repeats: false)
    }
}
