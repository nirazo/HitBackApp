//
//  HBSinglePlayScene.swift
//  BlockBreaker
//
//  Created by Kenzo on 2015/01/13.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBSinglePlayScene: SKScene, SKPhysicsContactDelegate {
    var life : Int = 0
    var stage : Int = 0
    var ballSpeed : Double = 0
    var lastUpdated : NSTimeInterval = 0
    var touchedFlag : Bool = false
    var score : Int = 0
    var combo : Int = 0
    var highScore : Int = 0
    // ハイスコア保存用NSUserDefaults
    let ud = NSUserDefaults.standardUserDefaults()
    
    
    // コンボ計算用（ボールを打った後1度でもブロックに当たって帰ってきたらコンボ継続）
    var blockBrokenInThisTurn : Bool = false
    var comboContinue : Bool = true
    
    private  struct Block {
        static let BLOCK_MARGIN = 16.0
        static let BLOCK_WIDTH = 40.0
        static let BLOCK_HEIGHT = 10.0
        static let BLOCK_MAX_LIFE = 1
        static let BLOCK_FALL_STEP = 25 // ブロックが落ちてくる幅。画面サイズをこの値で割った値ぶん落ちてくる
    }
    
    private struct Category {
        static let blockCategory : UInt32 = 0x1 << 0
        static let ballCategory : UInt32 = 0x1 << 1
        static let paddleCategory : UInt32 = 0x1 << 2
        static let worldCategory : UInt32 = 0x1 << 3
    }
    
    private struct Paddle {
        static let PADDLE_WIDTH = 70.0
        static let PADDLE_HEIGHT = 14.0
        static let PADDLE_RADIUS = 20.0
        static let PADDLE_Y = 180.0
        static let PADDLE_SPEED = 0.005
    }
    
    private struct Ball {
        static let BALL_RADIUS = 6.0
        static let BALL_BASESPEED = 300
        static let BALL_VELOCITY_X = 100.0
        static let BALL_VELOCITY_Y = 200.0
        static let BALL_ANGLE_MIN = 20.0
        static let BALL_ANGLE_MAX = 170.0
    }
    
    private struct Label {
        static let LABEL_MARGIN : CGFloat = 5.0
        static let LABEL_FONT_SIZE : CGFloat = 14.0
    }
    
    private struct Config {
        static let maxLife : Int = 2
        static let timeInterval : Double = 3.0 // 何秒おきにスピードアップするか
        // static let minNumOfBlocks : Int = 5
        static let maxNumOfBlocks : Int = 10
        static let scoreStep = 100
    }
    
    override convenience init(size: CGSize) {
        self.init(size:size, life: Config.maxLife, stage: 1)
    }
    
    init(size : CGSize, life : Int, stage: Int) {
        super.init(size: size)
        self.life = life
        self.stage = stage
        self.ballSpeed = Double(Ball.BALL_BASESPEED)
        
        self.addBlocks()
        self.addPaddle()
        self.addScoreLabel()
        self.addComboLabel()
        self.addLifeLabel()
        self.updateLifeLabel()
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = Category.worldCategory
        self.physicsWorld.contactDelegate = self        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - block related methods
    func addBlocks() {
        let numOfBlocks : Int = Int(getRandomNumber(Min: Float(Config.maxNumOfBlocks), Max: Float(Config.maxNumOfBlocks)))
        var blockWidth : Double = Block.BLOCK_WIDTH
        var blockHeight : Double = Block.BLOCK_HEIGHT
        
        for var i=0; i < numOfBlocks; i++ {
            var block : SKNode = self.newBlock()
            self.addChild(block)
        }
    }
    
    func newBlock() -> SKNode {
        var blockWidth : CGFloat = CGFloat(Block.BLOCK_WIDTH)
        var blockHeight : CGFloat = CGFloat(Block.BLOCK_HEIGHT)
        var maxLife : Int = Block.BLOCK_MAX_LIFE
        
        var block : SKSpriteNode = SKSpriteNode(color: SKColor.cyanColor(), size: CGSizeMake(blockWidth, blockHeight))
        var xMin = Block.BLOCK_WIDTH/2
        var xMax = (Int(self.frame.size.width) - Int(Block.BLOCK_WIDTH) / 2)
        var x = CGFloat(self.getRandomNumber(Min: Float(xMin), Max: Float(xMax)))
        
        var yMin = Paddle.PADDLE_Y * 2
        var yMax = self.frame.size.height - CGFloat(Block.BLOCK_HEIGHT/2)
        var y = CGFloat(self.getRandomNumber(Min: Float(yMin), Max: Float(yMax)))
        block.position = CGPointMake(x, y)
        
        block.name = "block"
        block.userData = NSMutableDictionary()
        block.userData?.setObject(maxLife, forKey: "life")
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.dynamic = false
        block.physicsBody?.categoryBitMask = Category.blockCategory
        self.updateBlockAlpha(block)
        return block
    }
    
    func updateBlockAlpha(block: SKNode) {
        var life = block.userData?.objectForKey("life") as Int
        block.alpha = 1.0
    }
    
    func decreaseBlockLife(block : SKNode) {
        var life : Int = Int(block.userData?.objectForKey("life") as NSNumber) - 1
        block.userData?.setObject(life, forKey: "life")
        self.updateBlockAlpha(block)
        if (life < 1) {
            self.blockBroken(block)
        }
        if (self.blockNodes()!.count < 1) {
            self.stage++
            self.addBlocks()
        }
    }
    
    func blockNodes() -> NSArray? {
        var nodes : NSMutableArray = [] as NSMutableArray
        self.enumerateChildNodesWithName("block", usingBlock: {node, stop in
            nodes.addObject(node)
        })
        return nodes
    }
    
    func blockBroken(block: SKNode) {
        self.removeNodeWithSpark(block)
        self.blockBrokenInThisTurn = true
        self.comboContinue = true
        if (self.comboContinue || self.combo == 0) {
            self.combo++
            self.updateComboLabel()
        }
        self.score += Config.scoreStep + self.comboBonus(Config.scoreStep, comboNum: self.combo)
        self.updateScoreLabel()
    }
    
    // ブロックを1段階分下に落とす
    func fallBlocks() {
        if (self.blockNodes()!.count != 0) {
            for blockNode : SKNode in self.blockNodes()! as [SKNode] {
                var dst : CGPoint = CGPointMake(blockNode.position.x, blockNode.position.y
                    - CGFloat(self.frame.size.height/CGFloat(Block.BLOCK_FALL_STEP)))
                
                var fall : SKAction = SKAction.moveTo(dst, duration: 1.0)
                var sequence : SKAction = SKAction.sequence([fall])
                blockNode.runAction(sequence, completion: {() -> Void in
                    self.judgeBlockHeightIsGameOver(blockNode)
                })
            }
        }
    }
    
    func judgeBlockHeightIsGameOver(block : SKNode) {
        if (block.position.y - CGFloat(Block.BLOCK_HEIGHT) / 2 < self.paddleNode().position.y + CGFloat(Paddle.PADDLE_RADIUS)) {
            self.gameOver()
        }
    }
    
    
    //MARK: - paddle related methods
    func addPaddle() {
        var radius : CGFloat = CGFloat(Paddle.PADDLE_RADIUS)
        var paddle : SKShapeNode = SKShapeNode()
        var paddleY : CGFloat = CGFloat(Paddle.PADDLE_Y)
        paddle.name = "paddle"
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddleY)
        var path : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius, 0, CGFloat(M_PI*2), true)
        paddle.path = path
        paddle.fillColor = SKColor.yellowColor()
        paddle.strokeColor = SKColor.yellowColor()
        
        paddle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.restitution = 1.0
        paddle.physicsBody?.linearDamping = 0
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.dynamic = false
        paddle.physicsBody?.categoryBitMask = Category.paddleCategory
        paddle.physicsBody?.contactTestBitMask = Category.ballCategory
        
        self.addChild(paddle)
        
    }
    
    func paddleNode() -> SKNode {
        return self.childNodeWithName("paddle")!
    }
    
    
    //MARK: - ball related methods
    func addBall() {
        var radius : CGFloat = CGFloat(Ball.BALL_RADIUS)
        var velocityX : CGFloat = 0.0 * CGFloat(self.ballSpeed)
        var velocityY : CGFloat = 1.0 * CGFloat(self.ballSpeed)
        var ball : SKShapeNode = SKShapeNode()
        ball.name = "ball"
        ball.position = CGPointMake(CGRectGetMidX(self.paddleNode().frame), CGRectGetMaxY(self.paddleNode().frame) + radius)
        var path : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius, 0, CGFloat(M_PI*2), true)
        ball.path = path
        ball.fillColor = SKColor.yellowColor()
        ball.strokeColor = SKColor.yellowColor()
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.velocity = CGVectorMake(velocityX + CGFloat(self.stage), velocityY)
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.friction = 0
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.categoryBitMask = Category.ballCategory
        ball.physicsBody?.contactTestBitMask = Category.blockCategory
        
        self.addChild(ball)
    }
    
    func ballNodes() -> NSArray?{
        var nodes : NSMutableArray = [] as NSMutableArray
        self.enumerateChildNodesWithName("ball", usingBlock: {node, stop in
            nodes.addObject(node)
        })
        return nodes
    }
    
    // ボールの角度が真横に近くならないよう補正
    func compensateBallAngle(ballPhysicsBody : SKPhysicsBody) {
        let velX :CGFloat = ballPhysicsBody.velocity.dx
        let velY : CGFloat = ballPhysicsBody.velocity.dy
        var rad : CGFloat = atan2(velY, velX)
        let angle : CGFloat = (rad / CGFloat(M_PI*2) * 360.0)
        var newAngle : CGFloat = angle
        
        if (CGFloat(abs(angle)) < CGFloat(Ball.BALL_ANGLE_MIN) || CGFloat(abs(angle)) > CGFloat(Ball.BALL_ANGLE_MAX)) {
            if (CGFloat(abs(angle)) < CGFloat(Ball.BALL_ANGLE_MIN)) {
                newAngle = angle == 0.0 ? CGFloat(Ball.BALL_ANGLE_MIN) : CGFloat(angle/abs(angle) * CGFloat(Ball.BALL_ANGLE_MIN))
            } else if (CGFloat(abs(angle)) > CGFloat(Ball.BALL_ANGLE_MAX)) {
                newAngle = angle == 180.0 ? CGFloat(Ball.BALL_ANGLE_MAX) : CGFloat(angle/abs(angle) * CGFloat(Ball.BALL_ANGLE_MAX))
            }
            
            var newRad : CGFloat = newAngle * CGFloat(M_PI*2) / 360
            let newDx = (cos(newRad) * CGFloat(self.ballSpeed))
            let newDy = (sin(newRad) * CGFloat(self.ballSpeed))
            var oldSpeed = (ballPhysicsBody.velocity.dx * ballPhysicsBody.velocity.dx) + (ballPhysicsBody.velocity.dy * ballPhysicsBody.velocity.dy)
            //println("old speed: \(oldSpeed)")
            //println("oldAngle: \(angle)")
            ballPhysicsBody.velocity = CGVectorMake(newDx, newDy)
            //println("newDx: \(newDx)")
            //println("newDy: \(newDy)")
            var newSpeed = (ballPhysicsBody.velocity.dx * ballPhysicsBody.velocity.dx) + (ballPhysicsBody.velocity.dy * ballPhysicsBody.velocity.dy)
            //println("new speed: \(newSpeed)")
            let newAngle = newRad / CGFloat(M_PI*2) * 360.0
            //println("newAngle: \(newAngle)")
        }
    }
    
    //MARK: - touch related methods
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (self.ballNodes()?.count == 0) {
            self.touchedFlag = true
                self.addBall()
            return
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches{
            let location = touch.locationInNode(self)
            paddleNode().position.x = location.x
        }
    }
    
    
    //MARK: - label related methods
    func addScoreLabel() {
        var margin : CGFloat = Label.LABEL_MARGIN
        var fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        var label : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "score: " + String(self.score)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        label.position = CGPointMake(CGRectGetMaxX(self.frame) - margin, CGRectGetMaxY(self.frame) - margin)
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.name = "scoreLabel"
        self.addChild(label)
    }
    
    func addComboLabel() {
        var margin : CGFloat = Label.LABEL_MARGIN
        var fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        var label : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = "combo: " + String(self.combo)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        label.position = CGPointMake(CGRectGetMaxX(self.frame) - margin, CGRectGetMaxY(self.frame) - margin*3)
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.name = "comboLabel"
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
    
    func updateScoreLabel() {
        self.scoreLabel().text = "score: " + String(self.score)
    }
    
    func updateComboLabel() {
        self.comboLabel().text = "combo: " + String(self.combo)
    }
    
    func updateLifeLabel() {
        var s : NSMutableString = ""
        for (var i = 0; i < self.life; i++) {
            s.appendString("♥")
        }
        self.lifeLabel().text = s
    }
    
    func scoreLabel() -> SKLabelNode {
        return self.childNodeWithName("scoreLabel")! as SKLabelNode
    }
    
    func comboLabel() -> SKLabelNode {
        return self.childNodeWithName("comboLabel")! as SKLabelNode
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
        if (firstBody.categoryBitMask & Category.blockCategory != 0) {
            if (secondBody.categoryBitMask & Category.ballCategory != 0) {
                self.decreaseBlockLife(firstBody.node!)
                secondBody = self.contactedBallAndBlock(secondBody.node! as SKShapeNode)
            }
        } else if (firstBody.categoryBitMask & Category.ballCategory != 0) {
            if (secondBody.categoryBitMask & Category.paddleCategory != 0) {
                firstBody = contactedBallAndPaddle(firstBody.node! as SKShapeNode)
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
        var scene : SKScene = HBGameOverScene(size: self.size, score: self.score)
        var transition : SKTransition = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    func nextLevel() {
        var scene : HBSinglePlayScene = HBSinglePlayScene(size: self.size, life: self.life, stage: self.stage+1)
        var transition : SKTransition = SKTransition.doorwayWithDuration(1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    /*
    乱数を生成するメソッド.
    */
    func getRandomNumber(Min _Min : Float, Max _Max : Float)->Float {
        
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (_Max - _Min) + _Min
    }
    
    
    // ボールとパドル衝突時のアクション
    func contactedBallAndPaddle(ball : SKShapeNode) -> SKPhysicsBody{
        // コンボ判定
        if (!self.blockBrokenInThisTurn) {
            self.comboContinue = false
            self.combo = 0
            self.updateComboLabel()
        }
        self.blockBrokenInThisTurn = false
        
        // 反射角計算
//        let ball_centerX : CGFloat = ball.position.x
//        let ball_centerY : CGFloat = ball.position.y + CGFloat(Paddle.PADDLE_Y/4)
//        let bar_centerX : CGFloat = self.paddleNode().position.x
//        let bar_centerY : CGFloat = self.paddleNode().position.y
//        let rad : CGFloat = atan2(ball_centerY - bar_centerY, ball_centerX - bar_centerX)
//        let ball_dx = CGFloat(cos(rad) * CGFloat(self.ballSpeed))
//        let ball_dy = CGFloat(sin(rad) * CGFloat(self.ballSpeed))
//        
//        ball.physicsBody?.velocity = CGVectorMake(ball_dx, ball_dy)
        
        let velX = ball.physicsBody?.velocity.dx
        let velY = ball.physicsBody?.velocity.dy
        let rad : CGFloat = atan2(velY!, velX!)
        self.compensateBallAngle(ball.physicsBody!)
        return ball.physicsBody!
    }
    
    // ボールとブロック衝突時のアクション
    func contactedBallAndBlock(ball : SKShapeNode) -> SKPhysicsBody{
        self.compensateBallAngle(ball.physicsBody!)
        return ball.physicsBody!
    }

    
    // コンボボーナス計算
    func comboBonus(base : Int, comboNum : Int) -> Int{
        if (comboNum == 0 | 1) {
            return 0
        }
        println("comboBonus: \(base/10 * (comboNum - 1))")
        return base/10 * (comboNum - 1)
    }
    
    
    // MARK: - Callbacks
    override func update(currentTime: NSTimeInterval) {
        if (self.lastUpdated != 0) {
            if ((self.lastUpdated + Config.timeInterval) <= currentTime) {
                //self.ballSpeed *= 1.0001
                self.lastUpdated = currentTime
                
                self.fallBlocks()
            }
        }
        if (self.touchedFlag) {
            self.touchedFlag = false
            self.lastUpdated = currentTime
        }
    }
    
    override func didEvaluateActions() {
        var paddleRadius : CGFloat = CGFloat(Paddle.PADDLE_RADIUS)
        
        var paddlePosition : CGPoint = self.paddleNode().position
        if (paddlePosition.x < paddleRadius) {
            paddlePosition.x = paddleRadius
        } else if (paddlePosition.x > CGRectGetWidth(self.frame) - paddleRadius) {
            paddlePosition.x = CGRectGetWidth(self.frame) - paddleRadius
        }
        self.paddleNode().position = paddlePosition
        
    }
    
    override func didSimulatePhysics() {
        if (self.ballNodes()?.count != 0) {
            for ballNode in self.ballNodes()! {
                if (ballNode.position.y < CGFloat(Ball.BALL_RADIUS*2)) {
                    self.removeNodeWithSpark(ballNode as SKNode)
                    self.lastUpdated = 0
                    self.ballSpeed = Double(Ball.BALL_BASESPEED)
                    self.life--
                    self.updateLifeLabel()
                    if (self.life < 1) {
                        if (self.score > ud.integerForKey("bestScore")) {
                            ud.setInteger(self.score, forKey: "bestScore")
                        }
                        self.gameOver()
                    }
                }
            }
        }
    }
}
