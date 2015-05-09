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
import Social

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
    var catView : UIImageView = UIImageView(image: UIImage(named: "spaceCat_down.png"))
    var scoreLabel : UILabel?
    var bestScoreLabel : UILabel?
    var buttonToRetry : UIButton?
    var buttonToTitle : UIButton?
    var buttonToStageSelect : UIButton?
    var buttonToFacebook : UIButton?
    var buttonToTwitter : UIButton?
    let ud = NSUserDefaults.standardUserDefaults()
    var stage : GAME_STAGE!
    
    let TITLE_MARGIN_Y_IPHONE6P : CGFloat = 60.0
    let TITLE_MARGIN_Y_IPHONE5AND6 : CGFloat = 30.0
    let TITLE_MARGIN_Y_IPHONE4ORLESS : CGFloat = 0.0
    
    // ねこ以下のボタン画像群のマージン
    let BUTTOMBUTTOM_MARGIN_Y_IPHONE6ORMORE : CGFloat = 30.0
    let BUTTOMBUTTOM_MARGIN_Y_IPHONE5ORLESS : CGFloat = 10.0
    
    private struct Label {
        static let LABEL_MARGIN : CGFloat = 18.0
        static let LABEL_FONT_SIZE : CGFloat = 20.0
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(score : Int, stage : GAME_STAGE) {
        super.init(nibName: nil, bundle: nil)
        println("gameOver init!!")
        self.score = score
        self.stage = stage
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iPhone5以上の端末であれば広告表示
        if (!IS_IPHONE_4_OR_LESS) {
            super.showAds(isWithStatusBar: true)
        }
        // 背景
        self.backgroundView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.backgroundView)
        self.view.sendSubviewToBack(self.backgroundView)
        
        // 地球
        self.earthView.frame.size = CGSize(width: self.view.frame.size.width * 1.2, height: self.view.frame.size.width)
        self.earthView.center = CGPoint(x: CGRectGetMidX(self.view.frame), y: self.view.frame.size.height)
        self.view.addSubview(self.earthView)

        // ゲームオーバーの文字
        var titleMarginY : CGFloat
        if (IS_IPHONE_4_OR_LESS) {
            titleMarginY = TITLE_MARGIN_Y_IPHONE4ORLESS
        } else if (IS_IPHONE_5 || IS_IPHONE_6) {
            titleMarginY = TITLE_MARGIN_Y_IPHONE5AND6
        } else {
            titleMarginY = TITLE_MARGIN_Y_IPHONE6P
        }
        
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
        let bestScore = ud.integerForKey(userDefaultsKeyDict[stage]!)
        bestScoreLabel!.text = String(bestScore)
        bestScoreLabel!.font = UIFont(name: "Helvetica", size: Label.LABEL_FONT_SIZE)
        bestScoreLabel!.textColor = UIColor.whiteColor()
        bestScoreLabel!.textAlignment = .Center
        bestScoreLabel!.center = CGPointMake(CGRectGetMidX(self.view.frame), bestScoreText.center.y + Label.LABEL_MARGIN + bestScoreLabel!.frame.size.height / 2)
        self.view.addSubview(bestScoreLabel!)

        
        // ねこ
        if (IS_IPHONE_4_OR_LESS) {
            self.catView.frame.size = CGSize(width: 100, height: 85.6)
        } else if (IS_IPHONE_5) {
            self.catView.frame.size = CGSize(width: 110, height: 94.2)
        } else {
            self.catView.frame.size = CGSize(width: 120, height: 102.8)
        }
        
        self.catView.center = CGPoint(x:CGRectGetMidX(self.view.frame) , y: CGRectGetMaxY(bestScoreLabel!.frame) + Label.LABEL_MARGIN + catView.frame.size.height / 2)
        self.view.addSubview(self.catView)
        
        // ここから下を基準に配置するよ
        var buttonsBottomBaseY : CGFloat
        if (IS_IPHONE_4_OR_LESS) {
            buttonsBottomBaseY = self.view.frame.size.height
        } else {
            buttonsBottomBaseY = self.view.frame.size.height - kGADAdSizeBanner.size.height
        }
        
        var buttonsMarginY : CGFloat
        if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
            buttonsMarginY = BUTTOMBUTTOM_MARGIN_Y_IPHONE5ORLESS
        } else {
            buttonsMarginY = BUTTOMBUTTOM_MARGIN_Y_IPHONE6ORMORE
        }
        
        // ステージセレクト画面へ飛ぶボタン
        buttonToStageSelect = UIButton()
        buttonToStageSelect!.bounds.size = CGSize(width: 120, height: 40)
        buttonToStageSelect!.center = CGPointMake(self.view.frame.width/2, buttonsBottomBaseY - buttonsMarginY - buttonToStageSelect!.frame.size.height / 2)
        buttonToStageSelect!.setBackgroundImage(UIImage(named: "toStageSelectButton.png"), forState: .Normal)
        buttonToStageSelect!.addTarget(self, action: "toStageSelectTapped:", forControlEvents: .TouchUpInside)
        buttonToStageSelect!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(buttonToStageSelect!)
        
        // タイトルへ戻るボタン
        buttonToTitle = UIButton()
        buttonToTitle?.setBackgroundImage(UIImage(named: "toTitleBUtton.png"), forState: .Normal)
        buttonToTitle!.bounds.size = CGSize(width: 120, height: 40)
        buttonToTitle!.center = CGPointMake(self.view.frame.width / 4, CGRectGetMinY(buttonToStageSelect!.frame) - buttonToTitle!.frame.size.height/2 - buttonsMarginY)
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
        
        // SNSボタンサイズ
        var snsButtonSize : CGFloat
        if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
            snsButtonSize = 48
        } else {
            snsButtonSize = 64
        }
        
        // facebookボタン
        buttonToFacebook = UIButton()
        buttonToFacebook!.bounds.size = CGSize(width: snsButtonSize, height: snsButtonSize)
        buttonToFacebook!.center = CGPointMake(self.view.frame.width / 4, CGRectGetMinY(buttonToTitle!.frame) - buttonToFacebook!.frame.size.height/2 - buttonsMarginY)
        buttonToFacebook!.setBackgroundImage(UIImage(named: "facebook-128.png"), forState: .Normal)
        buttonToFacebook!.addTarget(self, action: "toFacebookTapped:", forControlEvents: .TouchUpInside)
        buttonToFacebook!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(buttonToFacebook!)
        
        // twitterボタン
        buttonToTwitter = UIButton()
        buttonToTwitter!.bounds.size = CGSize(width: snsButtonSize, height: snsButtonSize)
        buttonToTwitter!.center = CGPointMake(self.view.frame.width*3/4, buttonToFacebook!.center.y)
        buttonToTwitter!.setBackgroundImage(UIImage(named: "twitter-128.png"), forState: .Normal)
        buttonToTwitter!.addTarget(self, action: "toTwitterTapped:", forControlEvents: .TouchUpInside)
        buttonToTwitter!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(buttonToTwitter!)
        
        
        if (self.bannerViewFooter != nil) {
            self.view.bringSubviewToFront(self.bannerViewFooter!)
        }
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
    
    //MARK: - Button selected methods
    func toTitleTapped(sender : AnyObject?) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func toRetryTapped(sender : AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func toStageSelectTapped(sender : AnyObject?) {
        var count : NSInteger = self.navigationController!.viewControllers.count - 3;
        var vc : HBStageSelectViewController = self.navigationController!.viewControllers[count] as! HBStageSelectViewController;
        self.navigationController?.popToViewController(vc, animated: true)
    }
    
    func toFacebookTapped(sender : AnyObject?) {
        postToSocial(self.score, stage: self.stage, type: SocialType.FACEBOOK)
    }
    
    func toTwitterTapped(sender : AnyObject?) {
        postToSocial(self.score, stage: self.stage, type: SocialType.TWITTER)
    }
    
    //MARK: - SNS
    func postToSocial(score: Int, stage: GAME_STAGE, type: SocialType) {
        if type == SocialType.TWITTER {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                var tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                tweetSheet.setInitialText("スコア: "
                    + String(score)
                    + "\n守れ！宇宙ねこ: "
                    + stageNameDict[stage]! + "ステージ\n")
                tweetSheet.addURL(NSURL(string: "https://itunes.apple.com/app/id963696838?l=ja"))
                tweetSheet.addImage(UIImage(named: "icon_180"))
                self.presentViewController(tweetSheet, animated: true, completion: nil)
            } else {
                println("tweet error")
                Alert().showAlert(self, title: "Tweetエラー",
                    buttonTitle: "OK",
                    message: "OSの設定画面からtwitterにログインしてください。", tag: 0)
            }
        } else if type == SocialType.FACEBOOK {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                var facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookSheet.setInitialText("スコア: "
                    + String(score)
                    + "\n守れ！宇宙ねこ: "
                    + stageNameDict[stage]! + "ステージ\n")
                facebookSheet.addURL(NSURL(string: "https://itunes.apple.com/app/id963696838?l=ja"))
                facebookSheet.addImage(UIImage(named: "icon_180"))
                self.presentViewController(facebookSheet, animated: true, completion: nil)
            } else {
                println("facebook post error")
                Alert().showAlert(self, title: "Facebook投稿エラー",
                    buttonTitle: "OK",
                    message: "OSの設定画面からFacebookにログインしてください。", tag: 0)
                
            }
        }
    }
}
