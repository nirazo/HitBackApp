//
//  HBVersusPlayScene.swift
//  BlockBreaker
//
//  Created by Kenzo on 2015/01/06.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBVersusPlayScene: SKScene, SKPhysicsContactDelegate {
    var life : Int = 0
    var stage : Int = 0
    var players : [String] = ["player1", "player2"]
    var shootStrong : Bool = false
    
    private  struct Block {
        static var BLOCK_MARGIN = 16.0
        static var BLOCK_WIDTH = 34.0
        static var BLOCK_HEIGHT = 16.0
        static var BLOCK_ROWS = 5
        static var BLOCK_MAX_LIFE = 3
    }
    
    private struct Category {
        static var blockCategory : UInt32 = 0x1 << 0
        static var ballCategory : UInt32 = 0x1 << 1
        static var player1Category : UInt32 = 0x1 << 2
        static var player2Category : UInt32 = 0x1 << 3
        static var worldCategory : UInt32 = 0x1 << 4
    }
    
    private struct Player {
        static var PLAYER_WIDTH = 70.0
        static var PLAYER_HEIGHT = 14.0
        static var PLAYER_Y = 60.0
        static var PLAYER_SPEED = 0.005
    }
    
    private struct Ball {
        static var BALL_RADIUS = 15.0
        static var BALL_VELOCITY_X = 90.0
        static var BALL_VELOCITY_Y = 250.0
    }
    
    private struct Label {
        static var LABEL_MARGIN : CGFloat = 5.0
        static var LABEL_FONT_SIZE : CGFloat = 14.0
    }
    
    private struct Config {
        static var maxLife : Int = 5
    }
    
    override convenience init(size: CGSize) {
        self.init(size:size, life: 5, stage: 1)
    }
    
    init(size : CGSize, life : Int, stage: Int) {
        super.init(size: size)
        self.life = life
        self.stage = stage
        
        self.addPlayer(CGPointMake(CGRectGetMidX(self.frame), CGFloat(Player.PLAYER_Y)), name: self.players[0])
        self.addPlayer(CGPointMake(CGRectGetMidX(self.frame), CGFloat(CGRectGetMaxY(self.frame) - CGFloat(Player.PLAYER_Y))), name: self.players[1])
        self.addStageLabel()
        self.addLifeLabel()
        self.updateLifeLabel()
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - block related methods
//    func addBlocks() {
//        var blockMargin : Double = Block.BLOCK_MARGIN
//        var blockWidth : Double = Block.BLOCK_WIDTH
//        var blockHeight : Double = Block.BLOCK_HEIGHT
//        var rows : Int = Block.BLOCK_ROWS as Int
//        var cols : Int = (Int(CGRectGetWidth(self.frame)) - Int(blockMargin)) / (Int(blockWidth) + Int(blockMargin))
//        var y : CGFloat = CGRectGetHeight(self.frame) - CGFloat(blockMargin) - CGFloat(blockHeight / 2)
//        
//        for var i=0; i<rows; i++ {
//            var x : CGFloat = CGFloat(blockMargin) + CGFloat(blockWidth/2)
//            for var j=0; j<cols; j++ {
//                var block : SKNode = self.newBlock()
//                block.position = CGPointMake(x, y)
//                x += CGFloat(blockWidth) + CGFloat(blockMargin)
//            }
//            y -= CGFloat(blockHeight) + CGFloat(blockMargin)
//        }
//    }
    
    func newBlock() -> SKNode {
        var blockWidth : CGFloat = CGFloat(Block.BLOCK_WIDTH)
        var blockHeight : CGFloat = CGFloat(Block.BLOCK_HEIGHT)
        var maxLife : Int = Block.BLOCK_MAX_LIFE
        
        var block : SKSpriteNode = SKSpriteNode(color: SKColor.cyanColor(), size: CGSizeMake(blockWidth, blockHeight))
        block.name = "block"
        block.userData = NSMutableDictionary()
        block.userData?.setObject(maxLife, forKey: "life")
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.dynamic = false
        block.physicsBody?.categoryBitMask = Category.blockCategory
        self.addChild(block)
        return block
    }
    
    func blockNodes() -> NSArray {
        var nodes : NSMutableArray = [] as NSMutableArray
        self.enumerateChildNodesWithName("block", usingBlock: {node, stop in
            nodes.addObject(node)
        })
        return nodes
    }
    
    
    // MARK: - player related methods
    func addPlayer(point : CGPoint, name : String) {
        var playerWidth : CGFloat = CGFloat(Player.PLAYER_WIDTH)
        var playerHeight : CGFloat = CGFloat(Player.PLAYER_HEIGHT)

        var player : SKSpriteNode = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(playerWidth, playerHeight))
        player.name = name
        player.position = point
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = false
        self.addChild(player)
        
        // 強打のための判定ポイントを作成
        var hitPoint : SKNode
        hitPoint = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(player.size.width, CGFloat(Ball.BALL_RADIUS*2) + 15.0))
        if (name == self.players[0]) {
            hitPoint.position = CGPointMake(player.position.x, CGFloat(player.position.y) + CGFloat(Player.PLAYER_HEIGHT/2) + CGFloat(Ball.BALL_RADIUS))
            self.player1Node().physicsBody?.categoryBitMask = Category.player1Category
            self.player1Node().physicsBody?.contactTestBitMask = Category.ballCategory
        } else {
            hitPoint.position = CGPointMake(player.position.x, CGFloat(player.position.y) - CGFloat(Player.PLAYER_HEIGHT/2) - CGFloat(Ball.BALL_RADIUS))
            self.player2Node().physicsBody?.categoryBitMask = Category.player2Category
            self.player2Node().physicsBody?.contactTestBitMask = Category.ballCategory
        }
        hitPoint.name = ("hitPoint_" + name)
        self.addChild(hitPoint)
    }
    
    func player1Node() -> SKNode {
        return self.childNodeWithName("player1")!
    }
    
    func player2Node() -> SKNode {
        return self.childNodeWithName("player2")!
    }
    
    func player1HitPoint() -> SKNode {
        return self.childNodeWithName("hitPoint_player1")!
    }
    
    func player2HitPoint() -> SKNode {
        return self.childNodeWithName("hitPoint_player2")!
    }
    
    func player1TapArea() -> CGRect {
        return CGRectMake(0.0, 0.0, self.frame.width, CGFloat(Player.PLAYER_Y))
    }
    
    func player2TapArea() -> CGRect {
        return CGRectMake(0.0, CGRectGetMaxY(self.frame) - CGFloat(Player.PLAYER_Y), self.frame.width, CGFloat(Player.PLAYER_Y))
    }
    
    // MARK: - ball related methods
    func addBall() {
        var radius : CGFloat = CGFloat(Ball.BALL_RADIUS)
        var velocityX : CGFloat = CGFloat(Ball.BALL_VELOCITY_X)
        var velocityY : CGFloat = CGFloat(Ball.BALL_VELOCITY_Y)
        var ball : SKShapeNode = SKShapeNode()
        ball.name = "ball"
        ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        var path : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius, 0, CGFloat(M_PI * 2), true)
        ball.path = path
        ball.fillColor = SKColor.yellowColor()
        ball.strokeColor = SKColor.yellowColor()
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.velocity = CGVectorMake(velocityX + CGFloat(self.stage), velocityY + CGFloat(self.stage))
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.friction = 0
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.categoryBitMask = Category.ballCategory
        
        self.addChild(ball)
    }
    
    func ballNode() -> SKNode?{
        return self.childNodeWithName("ball")
    }
    
    // MARK: - touch related methods
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (self.ballNode() == nil) {
            self.addBall()
            return
        }
        
        var touch : UITouch = touches.anyObject() as UITouch
        var location : CGPoint = touch.locationInNode(self)
        if CGRectContainsPoint(self.player1TapArea(), location) {
            if (CGRectContainsRect(self.player1HitPoint().frame, self.ballNode()!.frame)) {
                println("strong trigger!")
                self.shootStrong = true
            }
        } else if CGRectContainsPoint(self.player2TapArea(), location) {
            if (CGRectContainsRect(self.player2HitPoint().frame, self.ballNode()!.frame)) {
                println("strong trigger!")
                self.shootStrong = true
            }
        }
//        var speed :CGFloat = CGFloat(Player.PLAYER_SPEED)
//        var x : CGFloat = location.x
//        var diff : CGFloat = abs(x - self.paddleNode().position.x)
//        var duration : CGFloat = speed*diff
//        var move : SKAction = SKAction.moveToX(x, duration: NSTimeInterval(duration))
//        self.paddleNode().runAction(move)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches{
            let location = touch.locationInNode(self)
            if CGRectContainsPoint(self.player1TapArea(), location) {
                 player1Node().position.x = location.x
                player1HitPoint().position.x = location.x
            } else if CGRectContainsPoint(self.player2TapArea(), location) {
                 player2Node().position.x = location.x
                player2HitPoint().position.x = location.x
            }
        }
    }
    
    
    // MARK: - label related methods
    func addStageLabel() {
        var margin : CGFloat = Label.LABEL_MARGIN
        var fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        var label : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "stage" + String(self.stage)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        label.position = CGPointMake(CGRectGetMaxX(self.frame) - margin, CGRectGetMaxY(self.frame) - margin)
        label.fontSize = fontSize
        label.zPosition = 1.0
        self.addChild(label)
    }
    
    func addLifeLabel() {
        var margin : CGFloat = Label.LABEL_MARGIN
        var fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        var label : SKLabelNode = SKLabelNode(fontNamed: "HiraKakuProN-W3")
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.position = CGPointMake(margin, CGRectGetMaxY(self.frame) - margin)
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.color = SKColor.magentaColor()
        label.colorBlendFactor = 1.0
        label.name = "lifeLabel"
        self.addChild(label)
    }
    
    func updateLifeLabel() {
        var s : NSMutableString = ""
        for (var i = 0; i < self.life; i++) {
            s.appendString("♥")
        }
        self.lifeLabel().text = s
    }
    
    func lifeLabel() -> SKLabelNode {
        return self.childNodeWithName("lifeLabel")! as SKLabelNode
    }

    
    // MARK: - SKPhyscicsContactDelegate
    func didEndContact(contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody = SKPhysicsBody()
        var secondBody : SKPhysicsBody = SKPhysicsBody()
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & Category.ballCategory != 0) {
            if (secondBody.categoryBitMask & Category.player1Category != 0 || secondBody.categoryBitMask & Category.player2Category != 0) {
                println(self.shootStrong)
                if (self.shootStrong) {
                    var velocity = self.ballNode()?.physicsBody?.velocity
                    self.ballNode()?.physicsBody?.velocity = CGVector(dx: velocity!.dx*3, dy: velocity!.dy*3)
                } else {
                    self.resetBallSpeed()
                }
                self.shootStrong = false
            }
        }
    }
    
    // MARK: - Utilities
    func removeNodeWithSpark(node : SKNode) {
        var sparkPath : String = NSBundle.mainBundle().pathForResource("spark", ofType: "sks")!
        var spark : SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkPath) as SKEmitterNode
        spark.position = node.position
        spark.xScale = 0.3
        spark.yScale = 0.3
        self.addChild(spark)
        
        var fadeOut : SKAction = SKAction.fadeOutWithDuration(0.3)
        var remove : SKAction = SKAction.removeFromParent()
        var sequence : SKAction = SKAction.sequence([fadeOut, remove])
        spark.runAction(sequence)
        node.removeFromParent()
    }
    
    func gameOver() {
        var scene : SKScene = HBGameOverScene(size: self.size, score: 1)
        var transition : SKTransition = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    func nextLevel() {
        var scene : HBVersusPlayScene = HBVersusPlayScene(size: self.size, life: self.life, stage: self.stage+1)
        var transition : SKTransition = SKTransition.doorwayWithDuration(1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    // ボールの速度を初期値に戻す
    func resetBallSpeed () {
        var currentVelocity = self.ballNode()?.physicsBody?.velocity
        var dxMagnification : CGFloat = fabs(CGFloat(currentVelocity!.dx) / CGFloat(Ball.BALL_VELOCITY_X))
        var dyMagnification : CGFloat = fabs(CGFloat(currentVelocity!.dy) / CGFloat(Ball.BALL_VELOCITY_Y))
        self.ballNode()?.physicsBody?.velocity = CGVectorMake(currentVelocity!.dx / dxMagnification, currentVelocity!.dy / dyMagnification)
    }
    
    
    // MARK: - Callbacks
    override func update(currentTime: NSTimeInterval) {
//        if (Int(currentTime % 5) == 0) {
//            var velocity : CGVector? = self.ballNode()?.physicsBody?.velocity
//            velocity?.dx *= 1.001
//            velocity?.dy *= 1.001
//            self.ballNode()?.physicsBody?.velocity = velocity!
//        }
    }
    
    override func didEvaluateActions() {
        var width : CGFloat = CGFloat(Player.PLAYER_WIDTH)
        var width_hitPoint : CGFloat = CGFloat(self.player1HitPoint().frame.size.width)
        for nodeName in self.players {
            var player: SKNode = self.childNodeWithName(nodeName)!
            var hitPoint: SKNode = self.childNodeWithName("hitPoint_" + nodeName)!
            // playerのポジション補正
            var playerPosition : CGPoint = player.position
            if (playerPosition.x < width/2) {
                playerPosition.x = width/2
            } else if (playerPosition.x > CGRectGetWidth(self.frame) - width/2) {
                playerPosition.x = CGRectGetWidth(self.frame) - width/2
            }
            // hitPointのポジション補正
            var hitPointPosition : CGPoint = hitPoint.position
            if (hitPointPosition.x < width_hitPoint/2) {
                hitPointPosition.x = width_hitPoint/2
            } else if (hitPointPosition.x > CGRectGetWidth(self.frame) - width_hitPoint/2) {
                hitPointPosition.x = CGRectGetWidth(self.frame) - width_hitPoint/2
            }
            self.childNodeWithName(nodeName)?.position = playerPosition
            self.childNodeWithName("hitPoint_" + nodeName)?.position = hitPointPosition
        }
    }
    
    override func didSimulatePhysics() {
        if (self.ballNode() != nil && self.ballNode()?.position.y < CGFloat(Ball.BALL_RADIUS*2)) {
            self.removeNodeWithSpark(self.ballNode()!)
        } else if (self.ballNode() != nil && self.ballNode()?.position.y > CGRectGetMaxY(self.frame) - CGFloat(Ball.BALL_RADIUS*2)) {
            self.removeNodeWithSpark(self.ballNode()!)
        }
//            self.life--
//            self.updateLifeLabel()
//            if (self.life < 1) {
//                self.gameOver()
//            }
    }
}
