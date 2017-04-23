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
    var score = 0
    var bannerView: GADBannerView?
    var delegate : HBGameOverViewControllerDelegate?
    var backgroundView = UIImageView()
    var earthView = UIImageView(image: UIImage(named: "earth.png"))
    var gameOverLabelImageView = UIImageView(image: UIImage(named: "gameOverLabel.png"))
    var catView = UIImageView()
    var scoreLabel = UILabel()
    var bestScoreLabel = UILabel()
    var buttonToRetry = UIButton()
    var buttonToTitle = UIButton()
    var buttonToStageSelect = UIButton()
    var buttonToFacebook = UIButton()
    var buttonToTwitter = UIButton()
    let ud = UserDefaults.standard
    var stage : GAME_STAGE
    
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
    
    init(score : Int, stage : GAME_STAGE) {
        self.score = score
        self.stage = stage
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iPhone5以上の端末であれば広告表示
        if (!IS_IPHONE_4_OR_LESS) {
            super.showAds(isWithStatusBar: true)
        }
        // 背景
        self.backgroundView = UIImageView(image: UIImage(named: stageBackgroundImageNameDict[self.stage]!))
        self.backgroundView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.backgroundView)
        self.view.sendSubview(toBack: self.backgroundView)
        
        // 地球
        if (self.stage == GAME_STAGE.NORMAL) {
            self.earthView.frame.size = CGSize(width: self.view.frame.size.width * 1.2, height: self.view.frame.size.width)
            self.earthView.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.size.height)
            self.view.addSubview(self.earthView)
        }
        
        // ゲームオーバーの文字
        var titleMarginY : CGFloat
        if (IS_IPHONE_4_OR_LESS) {
            titleMarginY = TITLE_MARGIN_Y_IPHONE4ORLESS
        } else if (IS_IPHONE_5 || IS_IPHONE_6) {
            titleMarginY = TITLE_MARGIN_Y_IPHONE5AND6
        } else {
            titleMarginY = TITLE_MARGIN_Y_IPHONE6P
        }
        
        let gameOverWidth = self.view.frame.size.width - 15
        let gameOverHeight = gameOverWidth / 7
        self.gameOverLabelImageView.frame.size = CGSize(width: gameOverWidth, height: gameOverHeight)
        self.gameOverLabelImageView.center = CGPoint(x: self.view.frame.midX, y: self.gameOverLabelImageView.frame.size.height / 2 + titleMarginY)
        self.view.addSubview(self.gameOverLabelImageView)
        
        
        // スコアのテキスト
        let scoreText : UIImageView = UIImageView(image: UIImage(named: "scoreLabel_gameOver.png"))
        scoreText.frame.size = CGSize(width: 120, height: 37.747)
        scoreText.center = CGPoint(x: self.view.frame.midX, y: self.gameOverLabelImageView.frame.maxY + Label.LABEL_MARGIN + scoreText.frame.height / 2)
        self.view.addSubview(scoreText)
        
        // スコア表示
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        scoreLabel.text = String(self.score)
        scoreLabel.font = UIFont(name: "Helvetica", size: Label.LABEL_FONT_SIZE)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white
        scoreLabel.center = CGPoint(x: self.view.frame.midX, y: scoreText.center.y + Label.LABEL_MARGIN + scoreLabel.frame.size.height / 2)
        self.view.addSubview(scoreLabel)
        
        
        // ベストスコアのテキスト
        let bestScoreText : UIImageView = UIImageView(image: UIImage(named: "bestScoreLabel.png"))
        bestScoreText.frame.size = CGSize(width: 120, height: 31.063)
        bestScoreText.center = CGPoint(x: self.view.frame.midX, y: scoreLabel.frame.maxY + Label.LABEL_MARGIN + bestScoreText.frame.height / 2)
        self.view.addSubview(bestScoreText)
        
        // ベストスコア表示
        bestScoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let bestScore = ud.integer(forKey: bestScoreUserDefaultsKeyDict[self.stage]!)
        bestScoreLabel.text = String(bestScore)
        bestScoreLabel.font = UIFont(name: "Helvetica", size: Label.LABEL_FONT_SIZE)
        bestScoreLabel.textColor = .white
        bestScoreLabel.textAlignment = .center
        bestScoreLabel.center = CGPoint(x: self.view.frame.midX, y: bestScoreText.center.y + Label.LABEL_MARGIN + bestScoreLabel.frame.size.height / 2)
        self.view.addSubview(bestScoreLabel)

        
        // ねこ
        catView = UIImageView(image: UIImage(named: spaceCatDownImageNameDict[self.stage]!))
        if (IS_IPHONE_4_OR_LESS) {
            self.catView.frame.size = CGSize(width: 100, height: 85.6)
        } else if (IS_IPHONE_5) {
            self.catView.frame.size = CGSize(width: 110, height: 94.2)
        } else {
            self.catView.frame.size = CGSize(width: 120, height: 102.8)
        }
        
        self.catView.center = CGPoint(x: self.view.frame.midX , y: bestScoreLabel.frame.maxY + Label.LABEL_MARGIN + catView.frame.size.height / 2)
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
        buttonToStageSelect.bounds.size = CGSize(width: 120, height: 40)
        buttonToStageSelect.center = CGPoint(x: self.view.frame.width/2, y: buttonsBottomBaseY - buttonsMarginY - buttonToStageSelect.frame.size.height / 2)
        buttonToStageSelect.setBackgroundImage(UIImage(named: "toStageSelectButton.png"), for: .normal)
        buttonToStageSelect.addTarget(self, action: #selector(toStageSelectTapped(sender:)), for: .touchUpInside)
        buttonToStageSelect.setTitleColor(.white, for: .normal)
        self.view.addSubview(buttonToStageSelect)
        
        // タイトルへ戻るボタン
        buttonToTitle = UIButton()
        buttonToTitle.setBackgroundImage(UIImage(named: "toTitleBUtton.png"), for: .normal)
        buttonToTitle.bounds.size = CGSize(width: 120, height: 40)
        buttonToTitle.center = CGPoint(x: self.view.frame.width / 4, y: buttonToStageSelect.frame.minY - buttonToTitle.frame.size.height/2 - buttonsMarginY)
        buttonToTitle.setBackgroundImage(UIImage(named: "toTitleButton.png"), for: .normal)
        buttonToTitle.addTarget(self, action: #selector(toTitleTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(buttonToTitle)
        
        // リトライボタン
        buttonToRetry = UIButton()
        buttonToRetry.bounds.size = CGSize(width: 120, height: 40)
        buttonToRetry.center = CGPoint(x: self.view.frame.width*3/4, y: buttonToTitle.center.y)
        buttonToRetry.setBackgroundImage(UIImage(named: "retryButton.png"), for: .normal)
        buttonToRetry.addTarget(self, action: #selector(toRetryTapped(sender:)), for: .touchUpInside)
        buttonToRetry.setTitleColor(.white, for: .normal)
        self.view.addSubview(buttonToRetry)
        
        // SNSボタンサイズ
        var snsButtonSize : CGFloat
        if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
            snsButtonSize = 48
        } else {
            snsButtonSize = 64
        }
        
        // facebookボタン
        buttonToFacebook = UIButton()
        buttonToFacebook.bounds.size = CGSize(width: snsButtonSize, height: snsButtonSize)
        buttonToFacebook.center = CGPoint(x: self.view.frame.width / 4, y: buttonToTitle.frame.minY - buttonToFacebook.frame.size.height/2 - buttonsMarginY)
        buttonToFacebook.setBackgroundImage(UIImage(named: "facebook-128.png"), for: .normal)
        buttonToFacebook.addTarget(self, action: #selector(toFacebookTapped(sender:)), for: .touchUpInside)
        buttonToFacebook.setTitleColor(.white, for: .normal)
        self.view.addSubview(buttonToFacebook)
        
        // twitterボタン
        buttonToTwitter = UIButton()
        buttonToTwitter.bounds.size = CGSize(width: snsButtonSize, height: snsButtonSize)
        buttonToTwitter.center = CGPoint(x: self.view.frame.width*3/4, y: buttonToFacebook.center.y)
        buttonToTwitter.setBackgroundImage(UIImage(named: "twitter-128.png"), for: .normal)
        buttonToTwitter.addTarget(self, action: #selector(toTwitterTapped(sender:)), for: .touchUpInside)
        buttonToTwitter.setTitleColor(UIColor.white, for: .normal)
        self.view.addSubview(buttonToTwitter)
        
        
        if (self.bannerViewFooter != nil) {
            self.view.bringSubview(toFront: self.bannerViewFooter!)
        }
        super.showInterstitial()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.bannerView != nil {
            self.bannerView?.removeFromSuperview()
            self.bannerView = nil
        }
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Button selected methods
    func toTitleTapped(sender : AnyObject?) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func toRetryTapped(sender : AnyObject?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func toStageSelectTapped(sender : AnyObject?) {
        let count : NSInteger = self.navigationController!.viewControllers.count - 3;
        let vc : HBStageSelectViewController = self.navigationController!.viewControllers[count] as! HBStageSelectViewController;
        self.navigationController?.popToViewController(vc, animated: true)
    }
    
    func toFacebookTapped(sender : AnyObject?) {
        postToSocial(score: self.score, stage: self.stage, type: SocialType.FACEBOOK)
    }
    
    func toTwitterTapped(sender : AnyObject?) {
        postToSocial(score: self.score, stage: self.stage, type: SocialType.TWITTER)
    }
    
    //MARK: - SNS
    func postToSocial(score: Int, stage: GAME_STAGE, type: SocialType) {
        if type == SocialType.TWITTER {
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                guard let ts = tweetSheet else { return }
                ts.setInitialText("スコア: "
                    + String(score)
                    + "\n守れ！宇宙ねこ: "
                    + stageNameDict[stage]! + "ステージ\n")
                ts.add(URL(string: "https://itunes.apple.com/app/id963696838?l=ja"))
                ts.add(UIImage(named: "icon_180"))
                self.present(ts, animated: true, completion: nil)
            } else {
                print("tweet error")
                Alert().showAlert(viewController: self, title: "Tweetエラー",
                    buttonTitle: "OK",
                    message: "OSの設定画面からtwitterにログインしてください。", tag: 0)
            }
        } else if type == SocialType.FACEBOOK {
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let facebookSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                guard let fs = facebookSheet else { return }
                fs.setInitialText("スコア: "
                    + String(score)
                    + "\n守れ！宇宙ねこ: "
                    + stageNameDict[stage]! + "ステージ\n")
                fs.add(URL(string: "https://itunes.apple.com/app/id963696838?l=ja"))
                fs.add(UIImage(named: "icon_180"))
                self.present(fs, animated: true, completion: nil)
            } else {
                print("facebook post error")
                Alert().showAlert(viewController: self, title: "Facebook投稿エラー",
                    buttonTitle: "OK",
                    message: "OSの設定画面からFacebookにログインしてください。", tag: 0)
                
            }
        }
    }
}
