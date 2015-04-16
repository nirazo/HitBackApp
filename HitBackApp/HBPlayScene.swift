//
//  HBPlayScene.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/28.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

class HBPlayScene: SKScene, SKPhysicsContactDelegate {
    var life : Int = 0
    var stage : Int = 0
    var ballSpeed : Double = 0
    var lastSpeedUpTime : NSTimeInterval = 0
    var lastEnemyAddedTime : NSTimeInterval = 0
    var isFirstTouched : Bool = false // 経過時間測定用フラグ
    var isBallReady : Bool = false // ボールがセットされ、発射する直前の状態になっているか否か
    var isDisplayManipulatable : Bool = true
    var score : Int = 0
    var combo : Int = 0
    var highScore : Int = 0
    var bestScoreManager : BestScoreManager!
    
    // ハイスコア保存用NSUserDefaults
    let ud = NSUserDefaults.standardUserDefaults()
    var escapeDelegate : SceneEscapeProtocol?
    var touchesStartY : CGFloat? = 0.0 // touchesBeganが始まった際のy座標
    
    // コンボ計算用（ボールを打った後1度でもブロックに当たって帰ってきたらコンボ継続）
    var enemyBrokenInThisTurn : Bool = false
    var comboContinue : Bool = true
    
    // ボールのサイズ
    var ballSize : CGFloat = 0
    
    var normalTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat.png")!)
    var smileTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat_smile.png")!)
    var bounceTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat_bounce.png")!)
    var downTexture : SKTexture = SKTexture(image: UIImage(named: "spaceCat_down.png")!)
    
    let backgroundTexture : SKTexture = SKTexture(image: UIImage(named: "background")!)
    let earthTexture : SKTexture = SKTexture(image: UIImage(named: "earth")!)
    let scoreTexture : SKTexture = SKTexture(image: UIImage(named: "scoreLabel_gameScene")!)
    let comboTexture : SKTexture = SKTexture(image: UIImage(named: "comboLabel")!)
    
    let readyTextTexture : SKTexture = SKTexture(image: UIImage(named: "startText1")!)
    let goTextTexture : SKTexture = SKTexture(image: UIImage(named: "startText2")!)
    
    var scoreStringImage : SKSpriteNode?
    var comboStringImage : SKSpriteNode?
    
    var movableAreaNode : SKSpriteNode?
    
    // ノードの名前
    let touchAreaName : String = "touchArea"
    let touchTextName : String = "touchText"
    
    // userdefaultsのキーの名前
    let touchDisplayedKey : String = "touchAreaDisplayed"
    
    // パドルのベースの高さ
    var paddleBaseY : CGFloat?
    
    enum GAME_STATE : Int {
        case BEFORE_START = 0
        case NORMAL = 1
        case BEFORE_GAMEOVER = 2
    }
    var gameState : GAME_STATE = GAME_STATE.BEFORE_START
    
    struct Enemy {
        static let ENEMY_MARGIN = 16.0
    }
    
    struct Category {
        static let enemyCategory : UInt32 = 0x1 << 0
        static let ballCategory : UInt32 = 0x1 << 1
        static let paddleCategory : UInt32 = 0x1 << 2
        static let worldCategory : UInt32 = 0x1 << 3
    }
    
    struct Paddle {
        static let PADDLE_WIDTH = 70.0
        static let PADDLE_HEIGHT = 14.0
        static let PADDLE_RADIUS = 35.0
        static let PADDLE_BASE_Y_DEVIDE = 4 // 画面を何分割したところにパドルを置くか
        static let PADDLE_SPEED = 0.005
    }
    
    struct Ball {
        static let BALL_RADIUS_BIG = 17.0
        static let BALL_RADIUS_SMALL = 12.0
        static let BALL_BASESPEED = 400
        static let BALL_ANGLE_MIN = 20.0
        static let BALL_ANGLE_MAX = 170.0
        static let BALL_MAXSPEED = 600.0
    }
    
    struct Label {
        static let LABEL_MARGIN : CGFloat = 10.0
        static let LABEL_FONT_SIZE : CGFloat = 14.0
    }
    
//    struct Config {
//        static let maxLife : Int = 2
//        static let timeInterval : Double = 3.0 // 何秒おきにスピードアップするか
//        static let minNumOfEnemies : Int = 3
//        static let maxNumOfEnemies : Int = 5
//        static let scoreStep = 100
//        static let speedUp_rate = 20
//        static let emenyFrequency : Double = 4.3 // 何秒おきに敵が出現するかの初期値
//        static let emenyFrequency_MAX : Double = 2.5 // 何秒おきに敵が出現するかの最速値
//        static let changeEnemyFrequencySeconds = 0.2 // 敵が出現する頻度が何秒ずつ早くなっていくか
//        static let enemyQuickenLevels = 3 // 何レベルおきに敵が出現する頻度が早くなるか
//    }
    
    enum ENEMY_TYPE : Int {
        case NORMAL = 0
        case QUICK = 1
        case HEAVY = 2
        case QUICK_HEAVY = 3
    }
    
    init(size : CGSize, life : Int, stage: Int) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
