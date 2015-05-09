//
//  HBSinglePlayScene.swift
//  BlockBreaker
//
//  Created by Kenzo on 2015/01/13.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBSinglePlayScene: HBPlayScene {
    
    var normalTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat.png")!)
    var smileTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat_smile.png")!)
    var bounceTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat_bounce.png")!)
    var downTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat_down.png")!)
    
    let backgroundTexture : SKTexture = SKTexture(image: UIImage(named: "background")!)
    
    private struct Config {
        static let maxLife : Int = 2
        static let timeInterval : Double = 3.0 // 何秒おきにスピードアップするか
        static let minNumOfEnemies : Int = 3
        static let maxNumOfEnemies : Int = 5
        static let scoreStep = 100
        static let speedUp_rate = 20
        static let emenyFrequency : Double = 4.3 // 何秒おきに敵が出現するかの初期値
        static let emenyFrequency_MAX : Double = 2.5 // 何秒おきに敵が出現するかの最速値
        static let changeEnemyFrequencySeconds = 0.2 // 敵が出現する頻度が何秒ずつ早くなっていくか
        static let enemyQuickenLevels = 3 // 何レベルおきに敵が出現する頻度が早くなるか
    }
    
    convenience init(size: CGSize) {
        self.init(size:size, life: Config.maxLife, stage: 1)
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.bestScoreManager = BestScoreManager()
        self.life = Config.maxLife
        self.stage = 1
        self.score = 0
        self.combo = 0
        self.comboContinue = true
        self.ballSpeed = Double(Ball.BALL_BASESPEED)
        
        self.paddleBaseY = self.frame.height / CGFloat(Paddle.PADDLE_BASE_Y_DEVIDE)
        
        self.movableAreaNode = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: self.frame.width, height: CGFloat(Paddle.PADDLE_RADIUS * 3)))
        
        self.movableAreaNode!.position = CGPoint(x: self.frame.width / 2, y: self.paddleBaseY! + CGFloat(Paddle.PADDLE_RADIUS / 2))
        self.movableAreaNode!.alpha = 0.17
        self.addChild(self.movableAreaNode!)
        
        
        self.addPaddle()
        self.addScoreLabel()
        self.addComboLabel()
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = Category.worldCategory
        self.physicsWorld.contactDelegate = self
        
        self.isFirstTouched = false
        self.lastSpeedUpTime = 0
        self.lastEnemyAddedTime = 0
        
        self.displayStageStartLabel()
        
        self.ballSize = self.life == 2 ? CGFloat(Ball.BALL_RADIUS_BIG) : CGFloat(Ball.BALL_RADIUS_SMALL)
        self.addBall()
        
        // 背景
        var background = SKSpriteNode(texture: backgroundTexture)
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.size = self.frame.size
        background.alpha = 0.90
        background.zPosition = -10
        self.addChild(background)
        
        var earth = SKSpriteNode(texture: self.earthTexture)
        earth.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame))
        earth.size = CGSize(width: self.frame.size.width * 1.2, height: 250)
        earth.alpha = 0.80
        earth.zPosition = -10
        self.addChild(earth)
        
        self.showStartText()
    }
    
    //MARK: - Enemy related methods
    func addEnemy() {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        let numOfEnemies : Int = Int(HBUtils.getRandomNumber(Float(Config.minNumOfEnemies), Max: Float(Config.minNumOfEnemies + (self.level() / 5) * 2)))

        for var i=0; i < numOfEnemies; i++ {
            var enemyType : ENEMY_TYPE
            if (self.level() > 1) {
                enemyType = i%2 == 0 ? ENEMY_TYPE.NORMAL : ENEMY_TYPE.QUICK
            } else {
                enemyType = ENEMY_TYPE.NORMAL
            }
            var enemy : SKSpriteNode = self.newEnemy(enemyType)
            self.addChild(enemy)
        }
    }
    
    func newEnemy(type : ENEMY_TYPE) -> SKSpriteNode {
        var enemy : EnemyBase? = nil
        switch type {
        case ENEMY_TYPE.NORMAL:
            enemy = NormalEnemy(level: self.level(), category: Category.enemyCategory)
        case ENEMY_TYPE.QUICK:
            enemy = QuickEnemy(level: self.level(), category: Category.enemyCategory)
        default:
            break
        }
        var xMin = enemy!.size.width/2
        var xMax = (Int(self.frame.size.width) - Int(enemy!.size.width) / 2)
        var x = CGFloat(HBUtils.getRandomNumber(Float(xMin), Max: Float(xMax)))
        var y = self.frame.size.height
        enemy!.position = CGPointMake(x, y)
        return enemy!
    }
    
    
    // enemyの動きを止める
    func stopEnemies() {
        if (self.enemyNodes()?.count != 0) {
            for enemy in self.enemyNodes()! as! [SKSpriteNode!] {
                enemy.removeActionForKey("fallEnemy")
            }
        }
    }
    
    func enemyNodes() -> NSArray? {
        var nodes : NSMutableArray = [] as NSMutableArray
        self.enumerateChildNodesWithName("enemy", usingBlock: {node, stop in
            nodes.addObject(node)
        })
        return nodes
    }
    
    func judgeEnemyHeightIsGameOver(enemy : EnemyBase) -> Bool{
        if (enemy.position.y - CGFloat(enemy.size.height) / 2 < self.paddleBaseY!) {
            return true
        }
        return false
    }
    
    
    //MARK: - paddle related methods
    func addPaddle() {
        var radius : CGFloat = CGFloat(Paddle.PADDLE_RADIUS)
        var paddle : SKSpriteNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "spaceCat.png")!))
        paddle.size = CGSize(width: Paddle.PADDLE_RADIUS*2*1.05, height: Paddle.PADDLE_RADIUS*2)
        
        var paddleY : CGFloat = self.paddleBaseY!
        paddle.name = "paddle"
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddleY)
        var path : CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius, 0, CGFloat(M_PI*2), true)
        
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
        var radius : CGFloat = self.ballSize
        var ball : SKSpriteNode = self.life == Config.maxLife ?
            SKSpriteNode(texture: SKTexture(image: UIImage(named: "ball_covered.png")!)) :
            SKSpriteNode(texture: SKTexture(image: UIImage(named: "ball_normal.png")!))
        ball.name = "ball"
        ball.position = CGPointMake(CGRectGetMidX(self.paddleNode().frame), CGRectGetMaxY(self.paddleNode().frame) + radius)
        ball.size = CGSize(width: radius * 2, height: radius * 2)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.friction = 0
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.categoryBitMask = Category.ballCategory
        ball.physicsBody?.contactTestBitMask = Category.enemyCategory
        
        self.addChild(ball)
    }
    
    func shootBall() {
        var velocityX : CGFloat = 1.0/sqrt(2) * CGFloat(self.ballSpeed)
        var velocityY : CGFloat = 1.0/sqrt(2) * CGFloat(self.ballSpeed)
        if (self.ballNodes()?.count != 0) {
            for ballNode in self.ballNodes()! {
                var node : SKSpriteNode = ballNode as! SKSpriteNode
                node.physicsBody!.velocity = CGVectorMake(velocityX + CGFloat(self.stage), velocityY)
            }
        }
    }
    
    // ボールがアウトになった際の処理
    func ballIsDead(node : SKNode) {
        self.removeNodeWithSpark(node)
        self.life--
        self.changeBallSize()
        self.lastSpeedUpTime = 0
        self.combo = 0
        if (self.life > 0) {
            self.addBall()
        }
    }
    
    // ボールの動きを止める
    func stopBalls() {
        if (self.ballNodes()?.count != 0) {
            for ball in self.ballNodes()! as! [SKSpriteNode!] {
                ball!.physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)
            }
        }
    }
    
    // ballのノードの配列を返す
    func ballNodes() -> NSArray?{
        var nodes : NSMutableArray = [] as NSMutableArray
        self.enumerateChildNodesWithName("ball", usingBlock: {node, stop in
            nodes.addObject(node)
        })
        return nodes
    }
    
    // ballのノードを返す
    func ballNode() -> SKSpriteNode? {
        if (self.ballNodes()?.count != 0) {
            return self.ballNodes()![0] as? SKSpriteNode
        } else {
            return nil
        }
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
            ballPhysicsBody.velocity = CGVectorMake(newDx, newDy)
            let newAngle = newRad / CGFloat(M_PI*2) * 360.0
        }
    }
    
    // ボールの速度を補正する
    func compensateBallSpeed(ballPhysicsBody : SKPhysicsBody) {
        let velX :CGFloat = ballPhysicsBody.velocity.dx
        let velY : CGFloat = ballPhysicsBody.velocity.dy
        var rad : CGFloat = atan2(velY, velX)
        let newDx = (cos(rad) * CGFloat(self.ballSpeed))
        let newDy = (sin(rad) * CGFloat(self.ballSpeed))
        ballPhysicsBody.velocity = CGVectorMake(newDx, newDy)
    }
    
    
    func changeBallSize() {
        self.ballSize = self.life == Config.maxLife ? CGFloat(Ball.BALL_RADIUS_BIG) : CGFloat(Ball.BALL_RADIUS_SMALL)
    }
    
    func changeBallSpeed() {
        if (self.ballNode() != nil) {
            self.ballSpeed = self.ballSpeed < Ball.BALL_MAXSPEED ? self.ballSpeed + Double(Config.speedUp_rate) : Ball.BALL_MAXSPEED
            let velX : CGFloat = self.ballNode()!.physicsBody!.velocity.dx
            let velY : CGFloat = self.ballNode()!.physicsBody!.velocity.dy
            var rad : CGFloat = atan2(velY, velX)
            let newDx = (cos(rad) * CGFloat(self.ballSpeed))
            let newDy = (sin(rad) * CGFloat(self.ballSpeed))
            self.ballNode()!.physicsBody!.velocity = CGVectorMake(newDx, newDy)
            println("ballSpeed: \(self.ballSpeed)")
        }
    }
    
    func isBallMoving() -> Bool {
        return !(self.ballNode()?.physicsBody?.velocity.dx == 0.0 && self.ballNode()?.physicsBody?.velocity.dy == 0.0)
    }
    
    //MARK: - touch related methods
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        
        if(self.ballNode() != nil && !self.isBallMoving()) {
            self.isBallReady = true
            self.isFirstTouched = true
            //self.addBall()
            // 表情変える
            var anim = SKAction.animateWithTextures([self.normalTexture, self.normalTexture], timePerFrame: 0.5)
            self.paddleNode().runAction(anim)
        }
        if (self.stageStartLabel() != nil) {
            self.stageStartLabel()!.removeFromParent()
        }
        for touch in touches as! Set<UITouch> {
            let location = touch.locationInNode(self)
            self.touchesStartY = location.y
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        self.removeTouchAreaAndText()
        if (self.ballNodes()?.count != 0 && !self.isBallMoving()) {
            var ball = self.ballNodes()![0] as! SKSpriteNode
            if (ball.physicsBody?.velocity == CGVectorMake(0, 0) && self.isBallReady) {
                self.shootBall()
                self.isBallReady = false
            }
            return
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        
        var location : CGPoint?
        var prevPos : CGPoint?
        var currentPos : CGPoint?
        var changePosY : CGFloat?
        for touch in touches as! Set<UITouch> {
            prevPos = touch.previousLocationInNode(self)
            currentPos = touch.locationInNode(self)
            changePosY = currentPos!.y - prevPos!.y
        }
        
        self.paddleNode().position.x = currentPos!.x
        if (!self.isBallMoving()) {
            self.ballNode()?.position.x = self.paddleNode().position.x
        } else {
            self.paddleNode().position.y += changePosY!
        }
    }


    //MARK: - label related methods
    func addScoreLabel() {
        var margin : CGFloat = Label.LABEL_MARGIN
        var fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        // 「とくてん」の文字画像
        self.scoreStringImage = SKSpriteNode(texture: self.scoreTexture)
        self.scoreStringImage!.size = CGSize(width: 80, height: 17.46)
        self.scoreStringImage!.position = CGPointMake(margin + self.scoreStringImage!.size.width / 2, CGRectGetMaxY(self.frame) - margin * 2)
        self.scoreStringImage!.alpha = 1.00
        self.scoreStringImage!.zPosition = 1
        self.addChild(scoreStringImage!)
        
        // 得点表示用ラベル
        var label : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = String(self.score)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.position = CGPointMake(CGRectGetMaxX(self.scoreStringImage!.frame) + margin, self.scoreStringImage!.position.y)
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.name = "scoreLabel"
        self.addChild(label)
    }
    
    func addComboLabel() {
        var margin : CGFloat = Label.LABEL_MARGIN
        var fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        // 「コンボ」の文字画像
        self.comboStringImage = SKSpriteNode(texture: self.comboTexture)
        self.comboStringImage!.size = CGSize(width: 80, height: 17.46)
        self.comboStringImage!.position = CGPointMake(margin + self.comboStringImage!.size.width / 2, CGRectGetMaxY(self.scoreStringImage!.frame) - margin * 2 - self.comboStringImage!.size.height / 2)
        self.comboStringImage!.zPosition = 1
        comboStringImage!.alpha = 1.00
        self.addChild(self.comboStringImage!)

        var label : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = String(self.combo)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.position = CGPointMake(CGRectGetMaxX(self.comboStringImage!.frame) + margin, self.comboStringImage!.position.y)
        label.fontSize = fontSize
        label.name = "comboLabel"
        self.addChild(label)
    }
    
    
    func addLifeLabel() {
        var margin : CGFloat = Label.LABEL_MARGIN
        var fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        var label : SKLabelNode = SKLabelNode(fontNamed: "HiraKakuProN-W3")
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.position = CGPointMake(self.size.width - margin * 6, CGRectGetMaxY(self.frame) - margin)
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.color = SKColor.magentaColor()
        label.colorBlendFactor = 1.0
        label.name = "lifeLabel"
        self.addChild(label)
    }
    
    func updateScoreLabel() {
        self.scoreLabel().text = String(self.score)
    }
    
    func updateComboLabel() {
        self.comboLabel().text = String(self.combo)
    }
    
    func updateLifeLabel() {
        var s : NSMutableString = ""
        for (var i = 0; i < self.life; i++) {
            s.appendString("♥")
        }
        self.lifeLabel().text = s as String
    }
    
    func scoreLabel() -> SKLabelNode {
        return self.childNodeWithName("scoreLabel")! as! SKLabelNode
    }
    
    func comboLabel() -> SKLabelNode {
        return self.childNodeWithName("comboLabel")! as! SKLabelNode
    }
    
    func lifeLabel() -> SKLabelNode {
        return self.childNodeWithName("lifeLabel")! as! SKLabelNode
    }
    
    
    // MARK: - SKPhyscicsContactDelegate
    func didEndContact(contact: SKPhysicsContact) {
        if (self.gameState == GAME_STATE.BEFORE_GAMEOVER) {
            return
        }
        var firstBody : SKPhysicsBody = SKPhysicsBody()
        var secondBody : SKPhysicsBody = SKPhysicsBody()
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & Category.enemyCategory != 0) {
            if (secondBody.categoryBitMask & Category.ballCategory != 0) {
                secondBody = self.contactedBallAndEnemy(secondBody.node! as! SKSpriteNode)
                var contactedNode = firstBody.node! as! EnemyBase
                contactedNode.contactedWithBall()
                if (Int(contactedNode.userData?.objectForKey("life") as! NSNumber) < 1) {
                    
                    // 表情変える
                    var anim = SKAction.animateWithTextures([self.smileTexture, self.normalTexture], timePerFrame: 0.5)
                    self.paddleNode().runAction(anim)
                    
                    self.removeNodeWithSpark(contactedNode)
                    contactedNode.removeFromParent()
                    self.enemyBrokenInThisTurn = true
                    self.comboContinue = true
                    if (self.comboContinue || self.combo == 0) {
                        self.combo++
                        self.updateComboLabel()
                    }
                    self.score += Config.scoreStep + self.comboBonus(Config.scoreStep, comboNum: self.combo)
                    self.updateScoreLabel()
                }
            }
        } else if (firstBody.categoryBitMask & Category.ballCategory != 0) {
            if (secondBody.categoryBitMask & Category.paddleCategory != 0) {
                firstBody = contactedBallAndPaddle(firstBody.node! as! SKSpriteNode)
            }
        }
    }
    
    // MARK: - Utilities
    func level() -> Int {
        return Int(self.score / 1000)
    }
    
    func removeNodeWithSpark(node : SKNode) {
        var sparkPath : String = NSBundle.mainBundle().pathForResource("spark", ofType: "sks")!
        var spark : SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkPath) as! SKEmitterNode
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
        self.removeTouchAreaAndText()
        self.bestScoreManager.updateBestScoreForStage(GAME_STAGE.NORMAL, score: self.score)
        
        self.gameState = GAME_STATE.BEFORE_GAMEOVER
        // アニメーション消す
        self.paddleNode().removeAllActions()
        
        // 表情変える
        var anim = SKAction.setTexture(self.downTexture)
        self.paddleNode().runAction(anim)
        
        self.stopBalls()
        self.stopEnemies()
        
        // 横揺れアニメーション
        var right : SKAction = SKAction.moveByX(-10.0, y: 0.0, duration: 0.05)
        var left : SKAction = SKAction.moveByX(10, y: 0.0, duration: 0.05)
        var sequence : SKAction = SKAction.sequence([right, left, left, right])
        var repeatSequence : SKAction = SKAction.repeatAction(sequence, count: 6)
        self.paddleNode().runAction(repeatSequence, completion: {() -> Void in
            // 横揺れが終わったら、一旦止まってふらふらしながら落ちていくアニメーション
            var wait : SKAction = SKAction.waitForDuration(0.6)
            self.paddleNode().runAction(wait, completion: {() -> Void in
                var right : SKAction = SKAction.moveByX(-15.0, y: 0.0, duration: 0.1)
                var left : SKAction = SKAction.moveByX(15, y: 0.0, duration: 0.1)
                var swingSequence : SKAction = SKAction.sequence([right, left, left, right])
                var repeatSequence : SKAction = SKAction.repeatActionForever(swingSequence)
                self.paddleNode().runAction(repeatSequence)

                var fall : SKAction = SKAction.moveToY(CGFloat(-Paddle.PADDLE_RADIUS), duration: 1.20)
                self.paddleNode().runAction(fall, completion: {() -> Void in
                    self.view?.paused = true
                    self.escapeDelegate?.sceneEscape!(self, score: self.score)
                })
            })
        })
    }
    
    // ボールとパドル衝突時のアクション
    func contactedBallAndPaddle(ball : SKSpriteNode) -> SKPhysicsBody{
        // 回転
        var up : SKAction = SKAction.rotateByAngle(10 * CGFloat(M_PI*2) / 360, duration: 0.03)
        var down : SKAction = SKAction.rotateByAngle(-10 * CGFloat(M_PI*2) / 360, duration: 0.03)
        var sequence : SKAction = SKAction.sequence([up, down, down, up])
        var repeatSequence : SKAction = SKAction.repeatAction(sequence, count: 2)
        self.paddleNode().runAction(repeatSequence)
        
        // 表情変える
        var anim = SKAction.animateWithTextures([self.bounceTexture, self.normalTexture], timePerFrame: 0.5)
        self.paddleNode().runAction(anim)
        
        // コンボ判定
        if (!self.enemyBrokenInThisTurn) {
            self.comboContinue = false
            self.combo = 0
            self.updateComboLabel()
        }
        self.enemyBrokenInThisTurn = false
                
        let velX = ball.physicsBody?.velocity.dx
        let velY = ball.physicsBody?.velocity.dy
        let rad : CGFloat = atan2(velY!, velX!)
        self.compensateBallSpeed(ball.physicsBody!)
        self.compensateBallAngle(ball.physicsBody!)
        return ball.physicsBody!
    }
    
    // ボールとブロック衝突時のアクション
    func contactedBallAndEnemy(ball : SKSpriteNode) -> SKPhysicsBody{
        if (self.isBallReady) {
            self.shootBall()
            self.isBallReady = false
        }
        self.compensateBallSpeed(ball.physicsBody!)
        self.compensateBallAngle(ball.physicsBody!)
        return ball.physicsBody!
    }

    
    // コンボボーナス計算
    func comboBonus(base : Int, comboNum : Int) -> Int{
        if (comboNum == 0 | 1) {
            return 0
        }
        return base/10 * (comboNum - 1)
    }
    
    // ステージ開始前のテキスト表示
    func displayStageStartLabel() {
        var stageStartLabel = SKLabelNode(fontNamed: "HiraKakuProN-W3")
        stageStartLabel.text = "タップして準備、離して発射！"
        stageStartLabel.fontColor = UIColor.whiteColor()
        stageStartLabel.fontSize = 20
        stageStartLabel.name = "stageStartLabel"
        stageStartLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
    }
    
    // イントロダクション用のタッチエリアとテキストを削除
    func removeTouchAreaAndText() {
        var touchArea = self.childNodeWithName(self.touchAreaName)
        var touchText = self.childNodeWithName(self.touchTextName)
        if (touchArea != nil && touchText != nil) {
            touchArea?.removeFromParent()
            touchText?.removeFromParent()
            self.ud.setBool(true, forKey: self.touchDisplayedKey)
        }
    }
    
    func stageStartLabel() -> SKLabelNode? {
        return self.childNodeWithName("stageStartLabel") as? SKLabelNode
    }
    
    // MARK: - Callbacks
    override func update(currentTime: NSTimeInterval) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        
        if (self.lastSpeedUpTime != 0) {
            if ((self.lastSpeedUpTime + Config.timeInterval) <= currentTime) {
                self.changeBallSpeed()
                self.lastSpeedUpTime = currentTime
            }
        }
        
        var enemyJudge : NSTimeInterval = self.lastEnemyAddedTime + Config.emenyFrequency - NSTimeInterval(Config.changeEnemyFrequencySeconds * NSTimeInterval(self.level() / Config.enemyQuickenLevels))
        enemyJudge = enemyJudge > Config.emenyFrequency_MAX ? enemyJudge : Config.emenyFrequency_MAX
        if (enemyJudge <= currentTime) {
            self.addEnemy()
            self.lastEnemyAddedTime = currentTime
        }
        if (self.isFirstTouched && !self.isBallReady) {
            self.lastSpeedUpTime = currentTime
            self.isFirstTouched = false
        }
    }
    
    override func didEvaluateActions() {
        if (self.gameState == GAME_STATE.BEFORE_START) {
            return
        }
        
        var paddleRadius : CGFloat = CGFloat(Paddle.PADDLE_RADIUS)
        
        var paddlePosition : CGPoint = self.paddleNode().position
        var ballPosition : CGPoint? = self.ballNode()?.position
        
        // Paddleのxが画面端に来た場合
        if (self.gameState != GAME_STATE.BEFORE_GAMEOVER) {
            if (paddlePosition.x < paddleRadius) {
                paddlePosition.x = paddleRadius
            } else if (paddlePosition.x > CGRectGetWidth(self.frame) - paddleRadius) {
                paddlePosition.x = CGRectGetWidth(self.frame) - paddleRadius
            }
            
            // Paddleのyの可動範囲限定
            if (paddlePosition.y < self.paddleBaseY!) {
                paddlePosition.y = self.paddleBaseY!
            } else if (CGFloat(paddlePosition.y) > self.paddleBaseY! + CGFloat(Paddle.PADDLE_RADIUS)) {
                paddlePosition.y = self.paddleBaseY! + CGFloat(Paddle.PADDLE_RADIUS)
            }
            
            if (self.isBallReady) {
                ballPosition?.x = paddlePosition.x
                self.ballNode()?.position = ballPosition!
            }
            self.paddleNode().position = paddlePosition
        }
    }
    
    override func didSimulatePhysics() {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        
        if (self.ballNodes()?.count != 0) {
            if (self.ballNode()!.position.y < self.ballSize*2) {
                // 表情変える
                var anim = SKAction.animateWithTextures([self.normalTexture, self.downTexture], timePerFrame: 0.01)
                self.paddleNode().runAction(anim)
                self.ballIsDead(self.ballNode()! as SKNode)
                if (self.life < 1) {
                    self.gameOver()
                }
            }
        }
        if (self.enemyNodes()?.count != 0) {
            for enemyNode in self.enemyNodes()! {
                if (self.judgeEnemyHeightIsGameOver(enemyNode as! EnemyBase)) {
                    self.gameOver()
                    break
                }
            }
        }
    }
    
    
    // ----- ゲームスタート時のテキストエフェクト showIntroText()の直後に呼ばれる -----
    func showStartText() {
        if (self.gameState != GAME_STATE.BEFORE_START) {
            return
        }
        
        var readyTextNode = SKSpriteNode(texture: self.readyTextTexture)
        var goTextNode = SKSpriteNode(texture: self.goTextTexture)
        
        readyTextNode.size = CGSize(width: self.size.width * 2 / 3, height: self.size.width * 2 / 3 / 3.912)
        readyTextNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame) - 200)
        goTextNode.size = CGSize(width: self.size.width * 2 / 3, height: self.size.width * 2 / 3 / 5.318)
        goTextNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame) - 200)
        
        let scaleUp = SKAction.scaleTo(1.8, duration: 0.1)
        let scaleDown = SKAction.scaleTo(1.5, duration: 0.1)
        let scaleStay = SKAction.scaleBy(1.0, duration: 1.0)
        let fadeout = SKAction.fadeOutWithDuration(0.1)
        let remove = SKAction.removeFromParent()
        let readyTextSequence = SKAction.sequence([scaleStay, fadeout, remove])
        let goTextSequence    = SKAction.sequence([scaleUp, scaleDown, scaleStay, fadeout, remove])
        
        self.addChild(readyTextNode)
        readyTextNode.runAction(readyTextSequence, completion: {
            self.addChild(goTextNode)
            goTextNode.runAction(goTextSequence, completion: {
                self.gameState = GAME_STATE.NORMAL
                if (!self.ud.boolForKey(self.touchDisplayedKey)) {
                    var touchAreaNode : SKSpriteNode = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: self.size.width, height: CGRectGetMinY(self.movableAreaNode!.frame)))
                    touchAreaNode.position = CGPoint(x: self.frame.width / 2, y: CGRectGetMinY(self.movableAreaNode!.frame) / 2)
                    touchAreaNode.alpha = 0.40
                    touchAreaNode.name = self.touchAreaName
                    
                    let touchTextTexture : SKTexture = SKTexture(image: UIImage(named: "touchText")!)
                    var touchTextNode = SKSpriteNode(texture: touchTextTexture)
                    touchTextNode.size = CGSize(width: touchAreaNode.size.width, height: touchAreaNode.size.width * touchTextTexture.size().height / touchTextTexture.size().width)
                    touchTextNode.position = touchAreaNode.position
                    touchTextNode.name = self.touchTextName
                    
                    self.addChild(touchAreaNode)
                    self.addChild(touchTextNode)
                }
            })
        })
    }
}