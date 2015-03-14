//
//  HBTitleViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/12.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameKit

class HBTitleViewController: HBAbstractBannerAdViewController, GKGameCenterControllerDelegate, HBTutorialViewControllerDelegate {
    var catView : UIImageView = UIImageView(image: UIImage(named: "spaceCat.png")?)

    var bannerView: GADBannerView?
    var titleView : UIImageView = UIImageView(image: UIImage(named: "titleImage.png")?)
    var backgroundView : UIImageView = UIImageView(image: UIImage(named: "background.png")?)
    var earthView : UIImageView = UIImageView(image: UIImage(named: "earth.png")?)
    
    let TITLE_MARGIN_Y_IPHONE5ORMORE : CGFloat = 70.0
    let TITLE_MARGIN_Y_IPHONE4ORLESS : CGFloat = 35.0
    let PARTS_MARGIN_Y_IPHONE5ORMORE : CGFloat = 20.0
    let PARTS_MARGIN_Y_IPHONE4ORLESS : CGFloat = 10.0
    
    let gameCenterPlayer = GKLocalPlayer()
    
    // NSUserDefaults
    let ud = NSUserDefaults.standardUserDefaults()
    
    var isLogedIn = false
    
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required override init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var titleMarginY : CGFloat = IS_IPHONE_4_OR_LESS ? TITLE_MARGIN_Y_IPHONE4ORLESS : TITLE_MARGIN_Y_IPHONE5ORMORE
        var partsMarginY : CGFloat = IS_IPHONE_4_OR_LESS ? PARTS_MARGIN_Y_IPHONE4ORLESS : PARTS_MARGIN_Y_IPHONE5ORMORE
        
        // 背景
        self.backgroundView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.backgroundView)
        self.view.sendSubviewToBack(self.backgroundView)
        
        // 地球
        self.earthView.frame.size = CGSize(width: self.view.frame.size.width * 1.2, height: self.view.frame.size.width)
        self.earthView.center = CGPoint(x: CGRectGetMidX(self.view.frame), y: self.view.frame.size.height)
        self.view.addSubview(self.earthView)
        
        // タイトル
        var titleWidth = self.view.frame.size.width - 30
        var titleHeight = titleWidth / 2.6
        self.titleView.frame.size = CGSize(width: titleWidth, height: titleHeight)
        self.titleView.center = CGPointMake(CGRectGetMidX(self.view.frame), titleView.frame.size.height / 2 + titleMarginY)
        self.view.addSubview(self.titleView)
        
        // ねこ
        self.catView.frame.size = CGSize(width: 120, height: 102.8)
        self.catView.center = CGPoint(x:CGRectGetMidX(self.view.frame) , y: CGRectGetMaxY(self.titleView.frame) + self.catView.frame.size.height/2 + partsMarginY)
        self.catView.animationRepeatCount = 0
        self.view.addSubview(self.catView)
        
        // ねこのアニメーション
        let duration = 0.1
        let twist = M_PI / 18
        let reverse = -M_PI / 18
        
        let horizontalTwistAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        horizontalTwistAnimation.toValue = twist
        var rotateImage1 = self.catView.image?
        var rotateImage2 = self.catView.image?.rotateImage(8.0)
        var rotateImage3 = self.catView.image?.rotateImage(-8.0)
        self.catView.animationImages = [rotateImage1!, rotateImage2!, rotateImage1!, rotateImage3!, rotateImage1!]
        self.catView.animationRepeatCount = 0
        self.catView.animationDuration = 1.0
        
        // スタートボタン
        var singleStart : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 120, 40))
        singleStart.setBackgroundImage(UIImage(named: "startButton.png"), forState: .Normal)
        singleStart.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.catView.frame) + singleStart.frame.size.height/2 + partsMarginY)
        singleStart.addTarget(self, action: "singleStartTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(singleStart)
        
        // チュートリアル表示ボタン
        var tutorialButton : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 120, 40))
        tutorialButton.setBackgroundImage(UIImage(named: "tutorialButton.png"), forState: .Normal)
        tutorialButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(singleStart.frame) + tutorialButton.frame.size.height/2 + partsMarginY)
        tutorialButton.addTarget(self, action: "tutorialButtonTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(tutorialButton)
        
        // ランキング表示ボタン
        var scoreButton : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 120, 40))
        scoreButton.setBackgroundImage(UIImage(named: "rankingButton.png"), forState: .Normal)
        scoreButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(tutorialButton.frame) + scoreButton.frame.size.height/2 + partsMarginY)
        scoreButton.addTarget(self, action: "scoreButtonTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(scoreButton)

        // 広告表示
        super.showAds(isWithStatusBar: true)
        self.loginGameCenter()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.catView.startAnimating()
    }
    
    func singleStartTapped(sender: AnyObject?) {
        if (!ud.boolForKey("tutorialDisplayed")) {
            var vc : HBTutorialViewController = HBTutorialViewController()
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        var vc : HBSingleViewController = HBSingleViewController()
        self.navigationController?.pushViewController(vc, animated: true)        
    }
    
    func tutorialButtonTapped(sender: AnyObject?) {
        var vc : HBTutorialViewController = HBTutorialViewController()
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func scoreButtonTapped(sender: AnyObject?) {
        if self.isLogedIn != true {
            let alert = Alert()
            alert.showAlert(self, title: "きろく",
                buttonTitle: "OK",
                message: "ランキングが表示できません。\nネットワークにつながっているか、GameCenterにログインしているか確認してください。", tag: 0)
            loginGameCenter()
            return
        }
        self.gameCenterPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier : String!, error : NSError!) -> Void in
            if error != nil {
                println(error.localizedDescription)
            } else {
                let gameCenterController:GKGameCenterViewController = GKGameCenterViewController()
                gameCenterController.gameCenterDelegate = self
                gameCenterController.viewState = GKGameCenterViewControllerState.Leaderboards
                gameCenterController.leaderboardIdentifier = "spaceCat" //該当するLeaderboardのIDを指定します
                self.presentViewController(gameCenterController, animated: true, completion: nil)
            }
        })
    }
    
    func loginGameCenter() {
        //GameCenterにログインします。
        self.gameCenterPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil) {
                println("ログイン確認処理：失敗-ログイン画面を表示")
                self.presentViewController(viewController, animated: true, completion: nil)
            }else{
                println("ログイン確認処理：成功")
                println(error)
                if (error == nil){
                    println("ログイン認証：成功")
                    self.isLogedIn = true
                    BestScoreManager().syncBestScore()
                }else{
                    println("ログイン認証：失敗")
                }
            }
        }
    }
    
    func dismissGameViewControllers() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Delegate method for GKGameCenterDelegate
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!){
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    //MARK: - Delegate method for HBTutorialViewControllerDelegate
    func backButtonTapped() {
        self.ud.setBool(true, forKey: "tutorialDisplayed")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}