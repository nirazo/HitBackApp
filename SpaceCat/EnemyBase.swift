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
        super.init(texture: SKTexture(image: image), color: .clear, size: size)
        self.name = "enemy"
        self.userData = NSMutableDictionary()
        self.userData?.setObject(life, forKey: "life" as NSCopying)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = category
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 20)
        
        self.fallTime = HBUtils.getRandomNumber(Min: fallTime - self.speedDiff, Max: fallTime + self.speedDiff)
        self.fallDown(level: level)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fallDown(level: Int) {
        let fall = SKAction.moveTo(y: 0.0, duration: TimeInterval(self.fallTime))
        let sequence = SKAction.sequence([fall])
        self.run(sequence, withKey: "fallEnemy")
        let action1 = SKAction.rotate(byAngle: 5 * CGFloat(Float.pi * 2) / 360, duration: 0.1)
        let action2 = SKAction.rotate(byAngle: -5 * CGFloat(Float.pi * 2) / 360, duration: 0.1)
        let infinite = SKAction.sequence([action1,action2,action2,action1])
        let repetition = SKAction.repeatForever(infinite)
        self.run(repetition, withKey: "swingEnemy")
    }
    
    // ボールとの衝突時のアクション
    func contactedWithBall() {
        self.decreaseLife()
    }
    
    func decreaseLife() {
        let life : Int = Int(self.userData?.object(forKey: "life") as! NSNumber) - 1
        self.userData?.setObject(life, forKey: "life" as NSCopying)
        self.updateAlpha()
    }
    
    func updateAlpha() {
        _ = self.userData?.object(forKey: "life") as! Int
        self.alpha = 1.0
    }
    
}
