//
//  BBPlayScene.swift
//  BlockBreaker
//
//  Created by Kenzo on 2015/01/06.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBPlayScene: SKScene, SKPhysicsContactDelegate {
    var life : Int = 0
    var stage : Int = 0
    
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
        static var paddleCategory : UInt32 = 0x1 << 2
        static var worldCategory : UInt32 = 0x1 << 3
    }
    
    private struct Paddle {
        static var PADDLE_WIDTH = 70.0
        static var PADDLE_HEIGHT = 14.0
        static var PADDLE_Y = 40.0
        static var PADDLE_SPEED = 0.005
    }
    
    private struct Ball {
        static var BALL_RADIUS = 6.0
        static var BALL_VELOCITY_X = 80.0
        static var BALL_VELOCITY_Y = 200.0
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
        
        self.addBlocks()
        self.addPaddle()
        self.addStageLabel()
        self.addLifeLabel()
        self.updateLifeLabel()
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.contactDelegate = self    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // block related methods
    func addBlocks() {
        var blockMargin : Double = Block.BLOCK_MARGIN
        var blockWidth : Double = Block.BLOCK_WIDTH
        var blockHeight : Double = Block.BLOCK_HEIGHT
        var rows : Int = Block.BLOCK_ROWS as Int
        var cols : Int = (Int(CGRectGetWidth(self.frame)) - Int(blockMargin)) / (Int(blockWidth) + Int(blockMargin))
        var y : CGFloat = CGRectGetHeight(self.frame) - CGFloat(blockMargin) - CGFloat(blockHeight / 2)
        
        for var i=0; i<rows; i++ {
            var x : CGFloat = CGFloat(blockMargin) + CGFloat(blockWidth/2)
            for var j=0; j<cols; j++ {
                var block : SKNode = self.newBlock()
                block.position = CGPointMake(x, y)
                x += CGFloat(blockWidth) + CGFloat(blockMargin)
            }
            y -= CGFloat(blockHeight) + CGFloat(blockMargin)
        }
    }
    
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
        self.updateBlockAlpha(block)
        self.addChild(block)
        return block
    }
    
    func updateBlockAlpha(block: SKNode) {
        var life = block.userData?.objectForKey("life") as Int
        block.alpha = CGFloat(life) * 0.2
    }

    func decreaseBlockLife(block : SKNode) {
        var life : Int = Int(block.userData?.objectForKey("life") as NSNumber) - 1
        block.userData?.setObject(life, forKey: "life")
        self.updateBlockAlpha(block)
        if (life < 1) {
            self.removeNodeWithSpark(block)
        }
        if (self.blockNodes().count < 1) {
            self.nextLevel()
        }
    }
    
    func blockNodes() -> NSArray {
        var nodes : NSMutableArray = [] as NSMutableArray
        self.enumerateChildNodesWithName("block", usingBlock: {node, stop in
            nodes.addObject(node)
        })
        return nodes
    }
    
    
    // paddle related methods
    func addPaddle() {
        var paddleWidth : CGFloat = CGFloat(Paddle.PADDLE_WIDTH)
        var paddleHeight : CGFloat = CGFloat(Paddle.PADDLE_HEIGHT)
        var paddleY : CGFloat = CGFloat(Paddle.PADDLE_Y)

        var paddle : SKSpriteNode = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(paddleWidth, paddleHeight))
        paddle.name = "paddle"
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddleY)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.size)
        paddle.physicsBody?.dynamic = false
        self.addChild(paddle)
    }
    
    func paddleNode() -> SKNode {
        return self.childNodeWithName("paddle")!
    }

    
    // ball related methods
    func addBall() {
        var radius : CGFloat = CGFloat(Ball.BALL_RADIUS)
        var velocityX : CGFloat = CGFloat(Ball.BALL_VELOCITY_X)
        var velocityY : CGFloat = CGFloat(Ball.BALL_VELOCITY_Y)
        var ball : SKShapeNode = SKShapeNode()
        ball.name = "ball"
        ball.position = CGPointMake(CGRectGetMidX(self.paddleNode().frame), CGRectGetMaxY(self.paddleNode().frame) + radius)
        var path : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius, 0, CGFloat(M_2_PI), true)
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
        ball.physicsBody?.contactTestBitMask = Category.blockCategory
        
        self.addChild(ball)
    }
    
    func ballNode() -> SKNode?{
        return self.childNodeWithName("ball")
    }
    
    // touch related methods
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (self.ballNode() == nil) {
            self.addBall()
            return
        }
//        var touch : UITouch = touches.anyObject() as UITouch
//        var location : CGPoint = touch.locationInNode(self)
//        var speed :CGFloat = CGFloat(Paddle.PADDLE_SPEED)
//        
//        var x : CGFloat = location.x
//        var diff : CGFloat = abs(x - self.paddleNode().position.x)
//        var duration : CGFloat = speed*diff
//        var move : SKAction = SKAction.moveToX(x, duration: NSTimeInterval(duration))
//        self.paddleNode().runAction(move)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches{
            let location = touch.locationInNode(self)
            paddleNode().position.x = location.x
        }
    }
    
    
    // label related methods
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

    
    // SKPhyscicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody = SKPhysicsBody()
        var secondBody : SKPhysicsBody = SKPhysicsBody()
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & Category.blockCategory != 0) {
            if (secondBody.categoryBitMask & Category.ballCategory != 0) {
                self.decreaseBlockLife(firstBody.node!)
            }
        }
    }
    
    // Utilities
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
        var scene : SKScene = HBGameOverScene(size: self.size)
        var transition : SKTransition = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    func nextLevel() {
        var scene : HBPlayScene = HBPlayScene(size: self.size, life: self.life, stage: self.stage+1)
        var transition : SKTransition = SKTransition.doorwayWithDuration(1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    
    // Callbacks
    override func update(currentTime: NSTimeInterval) {
        if (Int(currentTime % 5) == 0) {
            var velocity : CGVector? = self.ballNode()?.physicsBody?.velocity
            velocity?.dx *= 1.001
            velocity?.dy *= 1.001
            self.ballNode()?.physicsBody?.velocity = velocity!
        }
    }
    
    override func didEvaluateActions() {
        var width : CGFloat = CGFloat(Paddle.PADDLE_WIDTH)
        
        var paddlePosition : CGPoint = self.paddleNode().position
        if (paddlePosition.x < width/2) {
            paddlePosition.x = width/2
        } else if (paddlePosition.x > CGRectGetWidth(self.frame) - width/2) {
            paddlePosition.x = CGRectGetWidth(self.frame) - width/2
        }
        self.paddleNode().position = paddlePosition
    }
    
    override func didSimulatePhysics() {
        if (self.ballNode() != nil && self.ballNode()?.position.y < CGFloat(Ball.BALL_RADIUS*2)) {
            self.removeNodeWithSpark(self.ballNode()!)
            self.life--
            self.updateLifeLabel()
            if (self.life < 1) {
                self.gameOver()
            }
        }
    }
    
}
