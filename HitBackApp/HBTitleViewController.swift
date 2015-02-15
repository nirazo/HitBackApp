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

class HBTitleViewController: UIViewController, GKGameCenterControllerDelegate {
    var catView : UIImageView = UIImageView(image: UIImage(named: "spaceCat.png")?)

    var bannerView: GADBannerView?
    var titleView : UIImageView = UIImageView(image: UIImage(named: "titleImage.png")?)
    var backgroundView : UIImageView = UIImageView(image: UIImage(named: "background.png")?)
    var earthView : UIImageView = UIImageView(image: UIImage(named: "earth.png")?)
    
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ねこ
        self.catView.frame.size = CGSize(width: 120, height: 102.8)
        self.catView.center = CGPoint(x:CGRectGetMidX(self.view.frame) , y: CGRectGetMidY(self.view.frame))
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
        self.titleView.center = CGPointMake(CGRectGetMidX(self.view.frame), titleView.frame.size.height / 2 + 70)
        self.view.addSubview(self.titleView)
        
        // スタートボタン
        var singleStart : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 150, 50))
        singleStart.setBackgroundImage(UIImage(named: "startButton.png"), forState: .Normal)
        singleStart.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.catView.frame) + singleStart.frame.size.height)
        singleStart.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        singleStart.addTarget(self, action: "singleStartTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(singleStart)
        
        // ランキング表示ボタン
        var scoreButton : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 150, 50))
        scoreButton.setBackgroundImage(UIImage(named: "rankingButton.png"), forState: .Normal)
        scoreButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(singleStart.frame) + scoreButton.frame.size.height)
        scoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        scoreButton.addTarget(self, action: "scoreButtonTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(scoreButton)

        
        // 広告表示
        var offsetX = (self.view.frame.size.width - kGADAdSizeBanner.size.width) / 2
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner, origin: CGPointMake(offsetX, self.view.frame.size.height - kGADAdSizeBanner.size.height))
        //self.bannerView = GADBannerView(adSize: GADAdSizeFullWidthPortraitWithHeight(kGADAdSizeBanner.size.height), origin: CGPointMake(0, CGFloat(self.view.frame.height - kGADAdSizeBanner.size.height)))
        //self.bannerView?.backgroundColor = UIColor.clearColor()
        self.bannerView?.adUnitID = "ca-app-pub-8756306138420194/2858977665" // 広告ユニットID
        //self.bannerView?.rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        self.bannerView?.rootViewController = self
        self.view?.addSubview(self.bannerView!)
        let request = GADRequest() // リクエストのプロパティにいろいろ設定するターゲティングとかいろいろできるよ
        request.testDevices = [GAD_SIMULATOR_ID] // 実機でテストする場合は、デバイスごとのIDをArrayに追加する(デバッグ時にコンソールにIDが表示されるよ)
        self.bannerView?.loadRequest(request)
        
        println("title viewDidLoad")
        
        self.loginGameCenter()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.catView.startAnimating()
    }
    
    func singleStartTapped(sender: AnyObject?) {
        var vc : HBSingleViewController = HBSingleViewController()
        self.navigationController?.pushViewController(vc, animated: true)        
    }
    
    func scoreButtonTapped(sender: AnyObject?) {
        var localPlayer = GKLocalPlayer()
        
        localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier : String!, error : NSError!) -> Void in
            if error != nil {
                println(error.localizedDescription)
            } else {
                let gameCenterController:GKGameCenterViewController = GKGameCenterViewController()
                gameCenterController.gameCenterDelegate = self
                gameCenterController.viewState = GKGameCenterViewControllerState.Leaderboards
                gameCenterController.leaderboardIdentifier = "SpaceCat" //該当するLeaderboardのIDを指定します
                self.presentViewController(gameCenterController, animated: true, completion: nil)
            }
        })
    }
    
    func loginGameCenter() {
        //GameCenterにログインします。
        let localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil) {
                println("ログイン確認処理：失敗-ログイン画面を表示")
                self.presentViewController(viewController, animated: true, completion: nil)
            }else{
                println("ログイン確認処理：成功")
                println(error)
                if (error == nil){
                    println("ログイン認証：成功")
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
}