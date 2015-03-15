//
//  HBGameOverViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/27.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameKit

protocol HBGameOverViewControllerDelegate {
    
    func toTitleTapped()
    func toRetryTapped()
    
}

class HBGameOverViewController: HBAbstractInterstitialAdViewController {
    var score : Int!
    var bannerView: GADBannerView?
    var delegate : HBGameOverViewControllerDelegate?
    var backgroundView : UIImageView = UIImageView(image: UIImage(named: "background.png"))
    var earthView : UIImageView = UIImageView(image: UIImage(named: "earth.png"))
    var gameOverLabelImageView : UIImageView = UIImageView(image: UIImage(named: "gameOverLabel.png"))
    var catView : UIImageView = UIImageView(image: UIImage(named: "spaceCat_down.png")?)
    var scoreLabel : UILabel?
    var bestScoreLabel : UILabel?
    var buttonToRetry : UIButton?
    var buttonToTitle : UIButton?
    let ud = NSUserDefaults.standardUserDefaults()
    
    let TITLE_MARGIN_Y_IPHONE5ORMORE : CGFloat = 75.0
    let TITLE_MARGIN_Y_IPHONE4ORLESS : CGFloat = 30.0
    
    private struct Label {
        static let LABEL_MARGIN : CGFloat = 18.0
        static let LABEL_FONT_SIZE : CGFloat = 20.0
    }
    
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(score : Int) {
        super.init()
        println("gameOver init!!")
        self.score = score
    }

    required override init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 広告表示
        super.showAds(isWithStatusBar: true)
        // 背景
        self.backgroundView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.backgroundView)
        self.view.sendSubviewToBack(self.backgroundView)
        
        // 地球
        self.earthView.frame.size = CGSize(width: self.view.frame.size.width * 1.2, height: self.view.frame.size.width)
        self.earthView.center = CGPoint(x: CGRectGetMidX(self.view.frame), y: self.view.frame.size.height)
        self.view.addSubview(self.earthView)

        // ゲームオーバーの文字
        var titleMarginY : CGFloat = IS_IPHONE_4_OR_LESS ? TITLE_MARGIN_Y_IPHONE4ORLESS : TITLE_MARGIN_Y_IPHONE5ORMORE
        var gameOverWidth = self.view.frame.size.width - 15
        var gameOverHeight = gameOverWidth / 7
        self.gameOverLabelImageView.frame.size = CGSize(width: gameOverWidth, height: gameOverHeight)
        self.gameOverLabelImageView.center = CGPointMake(CGRectGetMidX(self.view.frame), self.gameOverLabelImageView.frame.size.height / 2 + titleMarginY)
        self.view.addSubview(self.gameOverLabelImageView)
        
        
        // スコアのテキスト
        var scoreText : UIImageView = UIImageView(image: UIImage(named: "scoreLabel_gameOver.png"))
        scoreText.frame.size = CGSize(width: 120, height: 37.747)
        scoreText.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.gameOverLabelImageView.frame) + Label.LABEL_MARGIN + scoreText.frame.height / 2)
        self.view.addSubview(scoreText)
        
        // スコア表示
        scoreLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 30))
        scoreLabel!.text = String(self.score)
        scoreLabel!.font = UIFont(name: "Helvetica", size: Label.LABEL_FONT_SIZE)
        scoreLabel!.textAlignment = .Center
        scoreLabel!.textColor = UIColor.whiteColor()
        scoreLabel!.center = CGPointMake(CGRectGetMidX(self.view.frame), scoreText.center.y + Label.LABEL_MARGIN + scoreLabel!.frame.size.height / 2)
        self.view.addSubview(scoreLabel!)
        
        
        // ベストスコアのテキスト
        var bestScoreText : UIImageView = UIImageView(image: UIImage(named: "bestScoreLabel.png"))
        bestScoreText.frame.size = CGSize(width: 120, height: 31.063)
        bestScoreText.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(scoreLabel!.frame) + Label.LABEL_MARGIN + bestScoreText.frame.height / 2)
        self.view.addSubview(bestScoreText)
        
        // ベストスコア表示
        bestScoreLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 30))
        let bestScore = ud.integerForKey(BESTSCORE_KEY)
        bestScoreLabel!.text = String(bestScore)
        bestScoreLabel!.font = UIFont(name: "Helvetica", size: Label.LABEL_FONT_SIZE)
        bestScoreLabel!.textColor = UIColor.whiteColor()
        bestScoreLabel!.textAlignment = .Center
        bestScoreLabel!.center = CGPointMake(CGRectGetMidX(self.view.frame), bestScoreText.center.y + Label.LABEL_MARGIN + bestScoreLabel!.frame.size.height / 2)
        self.view.addSubview(bestScoreLabel!)

        
        // ねこ
        self.catView.frame.size = CGSize(width: 120, height: 102.8)
        self.catView.center = CGPoint(x:CGRectGetMidX(self.view.frame) , y: CGRectGetMaxY(bestScoreLabel!.frame) + Label.LABEL_MARGIN + catView.frame.size.height / 2)
        self.view.addSubview(self.catView)
        
        // タイトルへ戻るボタン
        buttonToTitle = UIButton()
        buttonToTitle?.setBackgroundImage(UIImage(named: "toTitleBUtton.png"), forState: .Normal)
        buttonToTitle!.bounds.size = CGSize(width: 120, height: 40)
        buttonToTitle!.center = CGPointMake(self.view.frame.width / 4, self.view.frame.size.height - kGADAdSizeBanner.size.height - 10 - buttonToTitle!.frame.size.height / 2)
        buttonToTitle!.setBackgroundImage(UIImage(named: "toTitleButton.png"), forState: .Normal)
        buttonToTitle!.addTarget(self, action: "toTitleTapped:", forControlEvents: .TouchUpInside)
        self.view.addSubview(buttonToTitle!)
        
        // リトライボタン
        buttonToRetry = UIButton()
        buttonToRetry!.bounds.size = CGSize(width: 120, height: 40)
        buttonToRetry!.center = CGPointMake(self.view.frame.width*3/4, buttonToTitle!.center.y)
        buttonToRetry!.setBackgroundImage(UIImage(named: "retryButton.png"), forState: .Normal)
        buttonToRetry!.addTarget(self, action: "toRetryTapped:", forControlEvents: .TouchUpInside)
        buttonToRetry!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(buttonToRetry!)

        self.view.bringSubviewToFront(self.bannerViewFooter!)
        super.showInterstitial()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if self.bannerView != nil {
            self.bannerView?.removeFromSuperview()
            self.bannerView = nil
        }
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func toTitleTapped(sender : AnyObject?) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func toRetryTapped(sender : AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
