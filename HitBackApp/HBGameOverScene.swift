//
//  BBGameOverScene.swift
//  BlockBreaker
//
//  Created by Kenzo on 2015/01/08.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBGameOverScene: SKScene {
    init(size: CGSize, score: Int) {
        let ud = NSUserDefaults.standardUserDefaults()
        
        super.init(size: size)
        var titleLabel : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue")
        titleLabel.text = "Game Over..."
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        titleLabel.fontSize = 40.0
        self.addChild(titleLabel)
        
        var scoreLabel : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue")
        scoreLabel.text = "スコア： \(score)"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), titleLabel.position.y - titleLabel.frame.size.height)
        scoreLabel.fontSize = 15.0
        self.addChild(scoreLabel)
        
        var bestScoreLabel : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue")
        let bestScore = ud.integerForKey("bestScore")
        bestScoreLabel.text = "ハイスコア： \(bestScore)"
        bestScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), scoreLabel.position.y - titleLabel.frame.size.height)
        bestScoreLabel.fontSize = 15.0
        self.addChild(bestScoreLabel)
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
