//
//  HBHighSpeedPlayScene.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/28.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBHighSpeedPlayScene: HBPlayScene {
    
    var normalTexture = SKTexture(image: UIImage(named: "spaceCat_red.png")!)
    var smileTexture = SKTexture(image: UIImage(named: "spaceCat_red_smile.png")!)
    var bounceTexture = SKTexture(image: UIImage(named: "spaceCat_red_bounce.png")!)
    var downTexture = SKTexture(image: UIImage(named: "spaceCat_red_down.png")!)
    
    let backgroundTexture : SKTexture = SKTexture(image: UIImage(named: "background_quick")!)
    
    private struct Config {
        static let maxLife = 2
        static let timeInterval : Double = 3.0 // 何秒おきにスピードアップするか
        static let minNumOfEnemies = 3
        static let maxNumOfEnemies = 5
        static let scoreStep = 100
        static let speedUp_rate = 20
        static let emenyFrequency : Double = 3.0 // 何秒おきに敵が出現するかの初期値
        static let emenyFrequency_MAX : Double = 2.0 // 何秒おきに敵が出現するかの最速値
        static let changeEnemyFrequencySeconds = 0.2 // 敵が出現する頻度が何秒ずつ早くなっていくか
        static let enemyQuickenLevels = 1 // 何レベルおきに敵が出現する頻度が早くなるか
    }
    
    convenience init(size: CGSize) {
        self.init(size:size, life: Config.maxLife, stage: 1)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.bestScoreManager = BestScoreManager()
        self.life = Config.maxLife
        self.stage = 1
        self.score = 0
        self.combo = 0
        self.comboContinue = true
        self.ballSpeed = Double(Ball.BALL_BASESPEED)
        
        self.paddleBaseY = self.frame.height / CGFloat(Paddle.PADDLE_BASE_Y_DEVIDE)
        
        self.movableAreaNode = SKSpriteNode(color: UIColor.rgb(r: 150, g: 150, b: 150, alpha: 1.0), size: CGSize(width: self.frame.width, height: CGFloat(Paddle.PADDLE_RADIUS * 3)))
        
        self.movableAreaNode!.position = CGPoint(x: self.frame.width / 2, y: self.paddleBaseY! + CGFloat(Paddle.PADDLE_RADIUS / 2))
        self.movableAreaNode!.alpha = 0.17
        self.addChild(self.movableAreaNode!)
        
        
        self.addPaddle()
        self.addScoreLabel()
        self.addComboLabel()
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = Category.worldCategory
        self.physicsWorld.contactDelegate = self
        
        self.isFirstTouched = false
        self.lastSpeedUpTime = 0
        self.lastEnemyAddedTime = 0
        
        self.displayStageStartLabel()
        
        self.ballSize = self.life == 2 ? CGFloat(Ball.BALL_RADIUS_BIG) : CGFloat(Ball.BALL_RADIUS_SMALL)
        self.addBall()
        
        // 背景
        let background = SKSpriteNode(texture: backgroundTexture)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.size = self.frame.size
        background.alpha = 0.90
        background.zPosition = -10
        self.addChild(background)
        
        self.showStartText()
    }
    
    //MARK: - Enemy related methods
    func addEnemy() {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        let numOfEnemies = Int(HBUtils.getRandomNumber(Min: Float(Config.minNumOfEnemies), Max: Float(Config.minNumOfEnemies + (self.level() / 5) * 2)))
        for _ in 0..<numOfEnemies {
            let enemyType = ENEMY_TYPE.QUICK
            let enemy = self.newEnemy(type: enemyType)
            self.addChild(enemy)
        }
    }
    
    func newEnemy(type : ENEMY_TYPE) -> SKSpriteNode {
        var enemy: EnemyBase
        switch type {
        case ENEMY_TYPE.NORMAL:
            enemy = NormalEnemy(level: self.level(), category: Category.enemyCategory)
        case ENEMY_TYPE.QUICK:
            enemy = QuickEnemy(level: self.level(), category: Category.enemyCategory)
        default:
            enemy = NormalEnemy(level: self.level(), category: Category.enemyCategory)
        }
        let xMin = enemy.size.width/2
        let xMax = (Int(self.frame.size.width) - Int(enemy.size.width) / 2)
        let x = CGFloat(HBUtils.getRandomNumber(Min: Float(xMin), Max: Float(xMax)))
        let y = self.frame.size.height
        enemy.position = CGPoint(x: x, y: y)
        return enemy
    }
    
    
    // enemyの動きを止める
    func stopEnemies() {
        if (!self.enemyNodes().isEmpty) {
            self.enemyNodes().forEach {
                $0.removeAction(forKey: "fallEnemy")
            }
        }
    }
    
    func enemyNodes() -> Array<EnemyBase> {
        var nodes = [EnemyBase]()
        self.enumerateChildNodes(withName: "enemy", using: { node, stop in
            if let n = node as? EnemyBase {
                nodes.append(n)
            }
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
        let radius : CGFloat = CGFloat(Paddle.PADDLE_RADIUS)
        let paddle : SKSpriteNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "spaceCat_red.png")!))
        paddle.size = CGSize(width: Paddle.PADDLE_RADIUS*2*1.05, height: Paddle.PADDLE_RADIUS*2)
        
        let paddleY : CGFloat = self.paddleBaseY!
        paddle.name = "paddle"
        paddle.position = CGPoint(x: self.frame.midX, y: paddleY)
        let path : CGMutablePath = CGMutablePath()
        path.addArc(center: .zero, radius: 0, startAngle: radius, endAngle: CGFloat(Float.pi * 2), clockwise: true)
        //CGPathAddArc(path, nil, 0, 0, radius, 0, CGFloat(Float.pi * 2), true)
        
        paddle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.restitution = 1.0
        paddle.physicsBody?.linearDamping = 0
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.categoryBitMask = Category.paddleCategory
        paddle.physicsBody?.contactTestBitMask = Category.ballCategory
        
        self.addChild(paddle)
        
    }
    
    func paddleNode() -> SKNode {
        return self.childNode(withName: "paddle")!
    }
    
    
    //MARK: - ball related methods
    func addBall() {
        let radius : CGFloat = self.ballSize
        let ball : SKSpriteNode = self.life == Config.maxLife ?
            SKSpriteNode(texture: SKTexture(image: UIImage(named: "ball_green_covered.png")!)) :
            SKSpriteNode(texture: SKTexture(image: UIImage(named: "ball_green_normal.png")!))
        ball.name = "ball"
        ball.position = CGPoint(x: self.paddleNode().frame.midX, y: self.paddleNode().frame.maxY + radius)
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
        let velocityX : CGFloat = 1.0/sqrt(2) * CGFloat(self.ballSpeed)
        let velocityY : CGFloat = 1.0/sqrt(2) * CGFloat(self.ballSpeed)
        if (!self.ballNodes().isEmpty) {
            for ballNode in self.ballNodes() {
                let node = ballNode
                node.physicsBody!.velocity = CGVector(dx: velocityX + CGFloat(self.stage), dy: velocityY)
            }
        }
    }
    
    // ボールがアウトになった際の処理
    func ballIsDead(node : SKNode) {
        self.removeNodeWithSpark(node: node)
        self.life -= 1
        self.changeBallSize()
        self.lastSpeedUpTime = 0
        self.combo = 0
        if (self.life > 0) {
            self.addBall()
        }
    }
    
    // ボールの動きを止める
    func stopBalls() {
        if (!self.ballNodes().isEmpty) {
            for ball in self.ballNodes() {
                ball.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            }
        }
    }
    
    // ballのノードの配列を返す
    func ballNodes() -> Array<SKSpriteNode>{
        var nodes = [SKSpriteNode]()
        self.enumerateChildNodes(withName: "ball", using: {node, stop in
            if let n = node as? SKSpriteNode {
                nodes.append(n)
            }
        })
        return nodes
    }
    
    // ballのノードを返す
    func ballNode() -> SKSpriteNode? {
        if (!self.ballNodes().isEmpty) {
            return self.ballNodes().first
        } else {
            return nil
        }
    }
    
    
    // ボールの角度が真横に近くならないよう補正
    func compensateBallAngle(ballPhysicsBody : SKPhysicsBody) {
        let velX :CGFloat = ballPhysicsBody.velocity.dx
        let velY : CGFloat = ballPhysicsBody.velocity.dy
        let rad : CGFloat = atan2(velY, velX)
        let angle : CGFloat = (rad / CGFloat(Float.pi * 2) * 360.0)
        var newAngle : CGFloat = angle
        
        if (CGFloat(abs(angle)) < CGFloat(Ball.BALL_ANGLE_MIN) || CGFloat(abs(angle)) > CGFloat(Ball.BALL_ANGLE_MAX)) {
            if (CGFloat(abs(angle)) < CGFloat(Ball.BALL_ANGLE_MIN)) {
                newAngle = angle == 0.0 ? CGFloat(Ball.BALL_ANGLE_MIN) : CGFloat(angle/abs(angle) * CGFloat(Ball.BALL_ANGLE_MIN))
            } else if (CGFloat(abs(angle)) > CGFloat(Ball.BALL_ANGLE_MAX)) {
                newAngle = angle == 180.0 ? CGFloat(Ball.BALL_ANGLE_MAX) : CGFloat(angle/abs(angle) * CGFloat(Ball.BALL_ANGLE_MAX))
            }
            
            let newRad : CGFloat = newAngle * CGFloat(Float.pi * 2) / 360
            let newDx = (cos(newRad) * CGFloat(self.ballSpeed))
            let newDy = (sin(newRad) * CGFloat(self.ballSpeed))
            ballPhysicsBody.velocity = CGVector(dx: newDx, dy: newDy)
            _ = newRad / CGFloat(Float.pi*2) * 360.0
        }
    }
    
    // ボールの速度を補正する
    func compensateBallSpeed(ballPhysicsBody : SKPhysicsBody) {
        let velX :CGFloat = ballPhysicsBody.velocity.dx
        let velY : CGFloat = ballPhysicsBody.velocity.dy
        let rad : CGFloat = atan2(velY, velX)
        let newDx = (cos(rad) * CGFloat(self.ballSpeed))
        let newDy = (sin(rad) * CGFloat(self.ballSpeed))
        ballPhysicsBody.velocity = CGVector(dx: newDx, dy: newDy)
    }
    
    
    func changeBallSize() {
        self.ballSize = self.life == Config.maxLife ? CGFloat(Ball.BALL_RADIUS_BIG) : CGFloat(Ball.BALL_RADIUS_SMALL)
    }
    
    func changeBallSpeed() {
        if (self.ballNode() != nil) {
            self.ballSpeed = self.ballSpeed < Ball.BALL_MAXSPEED ? self.ballSpeed + Double(Config.speedUp_rate) : Ball.BALL_MAXSPEED
            let velX : CGFloat = self.ballNode()!.physicsBody!.velocity.dx
            let velY : CGFloat = self.ballNode()!.physicsBody!.velocity.dy
            let rad : CGFloat = atan2(velY, velX)
            let newDx = (cos(rad) * CGFloat(self.ballSpeed))
            let newDy = (sin(rad) * CGFloat(self.ballSpeed))
            self.ballNode()!.physicsBody!.velocity = CGVector(dx: newDx, dy: newDy)
            print("ballSpeed: \(self.ballSpeed)")
        }
    }
    
    func isBallMoving() -> Bool {
        return !(self.ballNode()?.physicsBody?.velocity.dx == 0.0 && self.ballNode()?.physicsBody?.velocity.dy == 0.0)
    }
    
    //MARK: - touch related methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        
        if(self.ballNode() != nil && !self.isBallMoving()) {
            self.isBallReady = true
            self.isFirstTouched = true
            //self.addBall()
            // 表情変える
            let anim = SKAction.animate(with: [self.normalTexture, self.normalTexture], timePerFrame: 0.5)
            self.paddleNode().run(anim)
        }
        if (self.stageStartLabel() != nil) {
            self.stageStartLabel()!.removeFromParent()
        }
        for touch in touches {
            let location = touch.location(in: self)
            self.touchesStartY = location.y
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        self.removeTouchAreaAndText()
        if (!self.ballNodes().isEmpty && !self.isBallMoving()) {
            let ball = self.ballNodes().first
            if (ball?.physicsBody?.velocity == CGVector(dx: 0, dy: 0) && self.isBallReady) {
                self.shootBall()
                self.isBallReady = false
            }
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        
        var prevPos : CGPoint?
        var currentPos : CGPoint?
        var changePosY : CGFloat?
        for touch in touches {
            prevPos = touch.previousLocation(in: self)
            currentPos = touch.location(in: self)
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
        let margin : CGFloat = Label.LABEL_MARGIN
        let fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        // 「とくてん」の文字画像
        self.scoreStringImage = SKSpriteNode(texture: self.scoreTexture)
        self.scoreStringImage!.size = CGSize(width: 80, height: 17.46)
        self.scoreStringImage!.position = CGPoint(x: margin + self.scoreStringImage!.size.width / 2, y: self.frame.maxY - margin * 2)
        self.scoreStringImage!.alpha = 1.00
        self.scoreStringImage!.zPosition = 1
        self.addChild(scoreStringImage!)
        
        // 得点表示用ラベル
        let label : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = String(self.score)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        label.position = CGPoint(x: self.scoreStringImage!.frame.maxX + margin, y: self.scoreStringImage!.position.y)
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.name = "scoreLabel"
        self.addChild(label)
    }
    
    func addComboLabel() {
        let margin : CGFloat = Label.LABEL_MARGIN
        let fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        // 「コンボ」の文字画像
        self.comboStringImage = SKSpriteNode(texture: self.comboTexture)
        self.comboStringImage!.size = CGSize(width: 80, height: 17.46)
        self.comboStringImage!.position = CGPoint(x: margin + self.comboStringImage!.size.width / 2, y: self.scoreStringImage!.frame.maxY - margin * 2 - self.comboStringImage!.size.height / 2)
        self.comboStringImage!.zPosition = 1
        comboStringImage!.alpha = 1.00
        self.addChild(self.comboStringImage!)
        
        let label : SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = String(self.combo)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        label.position = CGPoint(x: self.comboStringImage!.frame.maxX + margin, y: self.comboStringImage!.position.y)
        label.fontSize = fontSize
        label.name = "comboLabel"
        self.addChild(label)
    }
    
    
    func addLifeLabel() {
        let margin : CGFloat = Label.LABEL_MARGIN
        let fontSize : CGFloat = Label.LABEL_FONT_SIZE
        
        let label : SKLabelNode = SKLabelNode(fontNamed: "HiraKakuProN-W3")
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        label.position = CGPoint(x: self.size.width - margin * 6, y: self.frame.maxY - margin)
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.color = SKColor.magenta
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
        var s = ""
        for _ in 0 ..< self.life {
            s.append("♥")
        }
        self.lifeLabel().text = s
    }
    
    func scoreLabel() -> SKLabelNode {
        return self.childNode(withName: "scoreLabel")! as! SKLabelNode
    }
    
    func comboLabel() -> SKLabelNode {
        return self.childNode(withName: "comboLabel")! as! SKLabelNode
    }
    
    func lifeLabel() -> SKLabelNode {
        return self.childNode(withName: "lifeLabel")! as! SKLabelNode
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
                secondBody = self.contactedBallAndEnemy(ball: secondBody.node! as! SKSpriteNode)
                let contactedNode = firstBody.node! as! EnemyBase
                contactedNode.contactedWithBall()
                if (Int(contactedNode.userData?.object(forKey: "life") as! NSNumber) < 1) {
                    
                    // 表情変える
                    let anim = SKAction.animate(with: [self.smileTexture, self.normalTexture], timePerFrame: 0.5)
                    self.paddleNode().run(anim)
                    
                    self.removeNodeWithSpark(node: contactedNode)
                    contactedNode.removeFromParent()
                    self.enemyBrokenInThisTurn = true
                    self.comboContinue = true
                    if (self.comboContinue || self.combo == 0) {
                        self.combo += 1
                        self.updateComboLabel()
                    }
                    self.score += Config.scoreStep + self.comboBonus(base: Config.scoreStep, comboNum: self.combo)
                    self.updateScoreLabel()
                }
            }
        } else if (firstBody.categoryBitMask & Category.ballCategory != 0) {
            if (secondBody.categoryBitMask & Category.paddleCategory != 0) {
                firstBody = contactedBallAndPaddle(ball: firstBody.node! as! SKSpriteNode)
            }
        }
    }
    
    // MARK: - Utilities
    func level() -> Int {
        return Int(self.score / 1000)
    }
    
    func removeNodeWithSpark(node : SKNode) {
        let sparkPath : String = Bundle.main.path(forResource: "spark", ofType: "sks")!
        let spark : SKEmitterNode = NSKeyedUnarchiver.unarchiveObject(withFile: sparkPath) as! SKEmitterNode
        spark.position = node.position
        spark.xScale = 0.3
        spark.yScale = 0.3
        self.addChild(spark)
        
        let fadeOut : SKAction = SKAction.fadeOut(withDuration: 0.3)
        let remove : SKAction = SKAction.removeFromParent()
        let sequence : SKAction = SKAction.sequence([fadeOut, remove])
        spark.run(sequence)
        node.removeFromParent()
    }
    
    func gameOver() {
        self.removeTouchAreaAndText()
        self.bestScoreManager.updateBestScoreForStage(stage: GAME_STAGE.HIGHSPEED, score: self.score)
        
        self.gameState = GAME_STATE.BEFORE_GAMEOVER
        // アニメーション消す
        self.paddleNode().removeAllActions()
        
        // 表情変える
        let anim = SKAction.setTexture(self.downTexture)
        self.paddleNode().run(anim)
        
        self.stopBalls()
        self.stopEnemies()
        
        // 横揺れアニメーション
        let right : SKAction = SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.05)
        let left : SKAction = SKAction.moveBy(x: 10, y: 0.0, duration: 0.05)
        let sequence : SKAction = SKAction.sequence([right, left, left, right])
        let repeatSequence : SKAction = SKAction.repeat(sequence, count: 6)
        self.paddleNode().run(repeatSequence, completion: {() -> Void in
            // 横揺れが終わったら、一旦止まってふらふらしながら落ちていくアニメーション
            let wait : SKAction = SKAction.wait(forDuration: 0.6)
            self.paddleNode().run(wait, completion: {() -> Void in
                let right : SKAction = SKAction.moveBy(x: -15.0, y: 0.0, duration: 0.1)
                let left : SKAction = SKAction.moveBy(x: 15, y: 0.0, duration: 0.1)
                let swingSequence : SKAction = SKAction.sequence([right, left, left, right])
                let repeatSequence : SKAction = SKAction.repeatForever(swingSequence)
                self.paddleNode().run(repeatSequence)
                
                let fall : SKAction = SKAction.moveTo(y: CGFloat(-Paddle.PADDLE_RADIUS), duration: 1.20)
                self.paddleNode().run(fall, completion: {() -> Void in
                    self.view?.isPaused = true
                    self.escapeDelegate?.sceneEscape!(scene: self, score: self.score)
                })
            })
        })
    }
    
    // ボールとパドル衝突時のアクション
    func contactedBallAndPaddle(ball : SKSpriteNode) -> SKPhysicsBody{
        // 回転
        let up : SKAction = SKAction.rotate(byAngle: 10 * CGFloat(Float.pi * 2) / 360, duration: 0.03)
        let down : SKAction = SKAction.rotate(byAngle: -10 * CGFloat(Float.pi * 2) / 360, duration: 0.03)
        let sequence : SKAction = SKAction.sequence([up, down, down, up])
        let repeatSequence : SKAction = SKAction.repeat(sequence, count: 2)
        self.paddleNode().run(repeatSequence)
        
        // 表情変える
        let anim = SKAction.animate(with: [self.bounceTexture, self.normalTexture], timePerFrame: 0.5)
        self.paddleNode().run(anim)
        
        // コンボ判定
        if (!self.enemyBrokenInThisTurn) {
            self.comboContinue = false
            self.combo = 0
            self.updateComboLabel()
        }
        self.enemyBrokenInThisTurn = false
        
        self.compensateBallSpeed(ballPhysicsBody: ball.physicsBody!)
        self.compensateBallAngle(ballPhysicsBody: ball.physicsBody!)
        return ball.physicsBody!
    }
    
    // ボールとブロック衝突時のアクション
    func contactedBallAndEnemy(ball : SKSpriteNode) -> SKPhysicsBody{
        if (self.isBallReady) {
            self.shootBall()
            self.isBallReady = false
        }
        self.compensateBallSpeed(ballPhysicsBody: ball.physicsBody!)
        self.compensateBallAngle(ballPhysicsBody: ball.physicsBody!)
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
        let stageStartLabel = SKLabelNode(fontNamed: "HiraKakuProN-W3")
        stageStartLabel.text = "タップして準備、離して発射！"
        stageStartLabel.fontColor = .white
        stageStartLabel.fontSize = 20
        stageStartLabel.name = "stageStartLabel"
        stageStartLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    }
    
    // イントロダクション用のタッチエリアとテキストを削除
    func removeTouchAreaAndText() {
        let touchArea = self.childNode(withName: self.touchAreaName)
        let touchText = self.childNode(withName: self.touchTextName)
        if (touchArea != nil && touchText != nil) {
            touchArea?.removeFromParent()
            touchText?.removeFromParent()
            self.ud.set(true, forKey: self.touchDisplayedKey)
        }
    }
    
    func stageStartLabel() -> SKLabelNode? {
        return self.childNode(withName: "stageStartLabel") as? SKLabelNode
    }
    
    // MARK: - Callbacks
    override func update(_ currentTime: TimeInterval) {
        if (self.gameState != GAME_STATE.NORMAL) {
            return
        }
        
        if (self.lastSpeedUpTime != 0) {
            if ((self.lastSpeedUpTime + Config.timeInterval) <= currentTime) {
                self.changeBallSpeed()
                self.lastSpeedUpTime = currentTime
            }
        }
        
        var enemyJudge : TimeInterval = self.lastEnemyAddedTime + Config.emenyFrequency - TimeInterval(Config.changeEnemyFrequencySeconds * TimeInterval(self.level() / Config.enemyQuickenLevels))
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
        
        let paddleRadius : CGFloat = CGFloat(Paddle.PADDLE_RADIUS)
        
        var paddlePosition : CGPoint = self.paddleNode().position
        var ballPosition : CGPoint? = self.ballNode()?.position
        
        // Paddleのxが画面端に来た場合
        if (self.gameState != GAME_STATE.BEFORE_GAMEOVER) {
            if (paddlePosition.x < paddleRadius) {
                paddlePosition.x = paddleRadius
            } else if (paddlePosition.x > self.frame.width - paddleRadius) {
                paddlePosition.x = self.frame.width - paddleRadius
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
        
        if (!self.ballNodes().isEmpty) {
            if (self.ballNode()!.position.y < self.ballSize*2) {
                // 表情変える
                let anim = SKAction.animate(with: [self.normalTexture, self.downTexture], timePerFrame: 0.01)
                self.paddleNode().run(anim)
                self.ballIsDead(node: self.ballNode()! as SKNode)
                if (self.life < 1) {
                    self.gameOver()
                }
            }
        }
        if (!self.enemyNodes().isEmpty) {
            for enemyNode in self.enemyNodes() {
                if (self.judgeEnemyHeightIsGameOver(enemy: enemyNode)) {
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
        
        let readyTextNode = SKSpriteNode(texture: self.readyTextTexture)
        let goTextNode = SKSpriteNode(texture: self.goTextTexture)
        
        readyTextNode.size = CGSize(width: self.size.width * 2 / 3, height: self.size.width * 2 / 3 / 3.912)
        readyTextNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 200)
        goTextNode.size = CGSize(width: self.size.width * 2 / 3, height: self.size.width * 2 / 3 / 5.318)
        goTextNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 200)
        
        let scaleUp = SKAction.scale(to: 1.8, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.5, duration: 0.1)
        let scaleStay = SKAction.scale(by: 1.0, duration: 1.0)
        let fadeout = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        let readyTextSequence = SKAction.sequence([scaleStay, fadeout, remove])
        let goTextSequence    = SKAction.sequence([scaleUp, scaleDown, scaleStay, fadeout, remove])
        
        self.addChild(readyTextNode)
        readyTextNode.run(readyTextSequence, completion: {
            self.addChild(goTextNode)
            goTextNode.run(goTextSequence, completion: {
                self.gameState = GAME_STATE.NORMAL
                if (!self.ud.bool(forKey: self.touchDisplayedKey)) {
                    let touchAreaNode : SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: self.size.width, height: self.movableAreaNode!.frame.minY))
                    touchAreaNode.position = CGPoint(x: self.frame.width / 2, y: self.movableAreaNode!.frame.minY / 2)
                    touchAreaNode.alpha = 0.40
                    touchAreaNode.name = self.touchAreaName
                    
                    let touchTextTexture : SKTexture = SKTexture(image: UIImage(named: "touchText")!)
                    let touchTextNode = SKSpriteNode(texture: touchTextTexture)
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
