//
//  EnemyBase.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/07.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyBase : SKSpriteNode {
    let speedDiff : Float = 2.0
    var fallTime : Float = 0.0
    
    init (size: CGSize, life: Int, level:Int, fallTime: Float, image: UIImage, category: UInt32) {
        super.init(texture: SKTexture(image: image), color: UIColor.clearColor(), size: size)
        self.name = "enemy"
        self.userData = NSMutableDictionary()
        self.userData?.setObject(life, forKey: "life")
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = false
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = category
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 20)
        
        self.fallTime = HBUtils.getRandomNumber(fallTime - self.speedDiff, Max: fallTime + self.speedDiff)
        self.fallDown(level)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fallDown(level: Int) {
        var fall : SKAction = SKAction.moveToY(0.0, duration: NSTimeInterval(self.fallTime))
        var sequence : SKAction = SKAction.sequence([fall])
        self.runAction(sequence, completion: {() -> Void in
        })
        var action1 : SKAction = SKAction.rotateByAngle(5 * CGFloat(M_PI*2) / 360, duration: 0.1)
        var action2 : SKAction = SKAction.rotateByAngle(-5 * CGFloat(M_PI*2) / 360, duration: 0.1)
        var infinite : SKAction = SKAction.sequence([action1,action2,action2,action1])
        var repeat : SKAction = SKAction.repeatActionForever(infinite)
        self.runAction(repeat)
    }
    
    // ボールとの衝突時のアクション
    func contactedWithBall() {
        self.decreaseLife()
    }
    
    func decreaseLife() {
        var life : Int = Int(self.userData?.objectForKey("life") as NSNumber) - 1
        self.userData?.setObject(life, forKey: "life")
        self.updateAlpha()
        if (life < 1) {
            self.broken()
        }
    }
    
    func broken() {
        self.removeNodeWithSpark()
    }
    
    func updateAlpha() {
        var life = self.userData?.objectForKey("life") as Int
        self.alpha = 1.0
    }
    
    func removeNodeWithSpark() {
        var sparkPath : String = NSBundle.mainBundle().pathForResource("spark", ofType: "sks")!
        var spark : SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkPath) as SKEmitterNode
        spark.position = self.position
        spark.xScale = 0.3
        spark.yScale = 0.3
        self.addChild(spark)
        
        var fadeOut : SKAction = SKAction.fadeOutWithDuration(0.3)
        var remove : SKAction = SKAction.removeFromParent()
        var sequence : SKAction = SKAction.sequence([fadeOut, remove])
        spark.runAction(sequence)
    }

}
