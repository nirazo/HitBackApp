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
    var catView = UIImageView(image: UIImage(named: "spaceCat.png"))

    var bannerView: GADBannerView?
    var titleView = UIImageView(image: UIImage(named: "titleImage.png"))
    var backgroundView = UIImageView(image: UIImage(named: "background.png"))
    var earthView = UIImageView(image: UIImage(named: "earth.png"))
    
    let TITLE_MARGIN_Y_IPHONE5ORMORE : CGFloat = 70.0
    let TITLE_MARGIN_Y_IPHONE4ORLESS : CGFloat = 35.0
    let PARTS_MARGIN_Y_IPHONE5ORMORE : CGFloat = 20.0
    let PARTS_MARGIN_Y_IPHONE4ORLESS : CGFloat = 10.0
    
    let gameCenterPlayer = GKLocalPlayer()
    
    // NSUserDefaults
    let ud = UserDefaults.standard
    
    var isLogedIn = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleMarginY : CGFloat = IS_IPHONE_4_OR_LESS ? TITLE_MARGIN_Y_IPHONE4ORLESS : TITLE_MARGIN_Y_IPHONE5ORMORE
        let partsMarginY : CGFloat = IS_IPHONE_4_OR_LESS ? PARTS_MARGIN_Y_IPHONE4ORLESS : PARTS_MARGIN_Y_IPHONE5ORMORE
        
        // 背景
        self.backgroundView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.backgroundView)
        self.view.sendSubview(toBack: self.backgroundView)
        
        // 地球
        self.earthView.frame.size = CGSize(width: self.view.frame.size.width * 1.2, height: self.view.frame.size.width)
        self.earthView.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.size.height)
        self.view.addSubview(self.earthView)
        
        // タイトル
        let titleWidth = self.view.frame.size.width - 30
        let titleHeight = titleWidth / 2.6
        self.titleView.frame.size = CGSize(width: titleWidth, height: titleHeight)
        self.titleView.center = CGPoint(x: self.view.frame.midX, y:titleView.frame.size.height / 2 + titleMarginY)
        self.view.addSubview(self.titleView)
        
        // ねこ
        self.catView.frame.size = CGSize(width: 120, height: 102.8)
        self.catView.center = CGPoint(x: self.view.frame.midX , y: self.titleView.frame.maxY + self.catView.frame.size.height/2 + partsMarginY)
        self.view.addSubview(self.catView)
        
        // ねこのアニメーション
        let twist = Float.pi / 18
        
        let horizontalTwistAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        horizontalTwistAnimation.toValue = twist
        let rotateImage1 = self.catView.image
        let rotateImage2 = self.catView.image?.rotate(degree: 8.0)
        let rotateImage3 = self.catView.image?.rotate(degree: -8.0)
        self.catView.animationImages = [rotateImage1!, rotateImage2!, rotateImage1!, rotateImage3!, rotateImage1!]
        self.catView.animationRepeatCount = 0
        self.catView.animationDuration = 1.0
        
        // スタートボタン
        let singleStart : UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 120, height: 40))
        singleStart.setBackgroundImage(UIImage(named: "startButton.png"), for: .normal)
        singleStart.center = CGPoint(x: self.view.frame.midX, y: self.catView.frame.maxY + singleStart.frame.size.height/2 + partsMarginY)
        singleStart.addTarget(self, action: #selector(singleStartTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(singleStart)
        
        // チュートリアル表示ボタン
        let tutorialButton : UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 120, height: 40))
        tutorialButton.setBackgroundImage(UIImage(named: "tutorialButton.png"), for: .normal)
        tutorialButton.center = CGPoint(x: self.view.frame.midX, y: singleStart.frame.maxY + tutorialButton.frame.size.height/2 + partsMarginY)
        tutorialButton.addTarget(self, action: #selector(tutorialButtonTapped(sender: )), for:.touchUpInside)
        self.view.addSubview(tutorialButton)
        
        // ランキング表示ボタン
        let scoreButton : UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 120, height: 40))
        scoreButton.setBackgroundImage(UIImage(named: "rankingButton.png"), for: .normal)
        scoreButton.center = CGPoint(x: self.view.frame.midX, y: tutorialButton.frame.maxY + scoreButton.frame.size.height/2 + partsMarginY)
        scoreButton.addTarget(self, action: #selector(scoreButtonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(scoreButton)

        // 広告表示
        super.showAds(isWithStatusBar: true)
        self.loginGameCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.catView.startAnimating()
    }
    
    func singleStartTapped(sender: AnyObject?) {
        let vc : HBStageSelectViewController = HBStageSelectViewController()
        self.navigationController?.pushViewController(vc, animated: true)        
    }
    
    func tutorialButtonTapped(sender: AnyObject?) {
        let vc : HBTutorialViewController = HBTutorialViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func scoreButtonTapped(sender: AnyObject?) {
        if self.isLogedIn != true {
            let alert = Alert()
            alert.showAlert(viewController: self, title: "きろく",
                buttonTitle: "OK",
                message: "ランキングが表示できません。\nネットワークにつながっているか、GameCenterにログインしているか確認してください。", tag: 0)
            loginGameCenter()
            return
        }
        self.gameCenterPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifier : String!, error : NSError!) -> Void in
            if error != nil {
                //println(error.localizedDescription)
            } else {
                let gameCenterController:GKGameCenterViewController = GKGameCenterViewController()
                gameCenterController.gameCenterDelegate = self
                gameCenterController.viewState = GKGameCenterViewControllerState.leaderboards
                gameCenterController.leaderboardIdentifier = "spaceCat" //該当するLeaderboardのIDを指定します
                self.present(gameCenterController, animated: true, completion: nil)
            }
        } as? (String?, Error?) -> Void)
    }
    
    func loginGameCenter() {
        //GameCenterにログインします。
        self.gameCenterPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil) {
                print("ログイン確認処理：失敗-ログイン画面を表示")
                self.present(viewController!, animated: true, completion: nil)
            }else{
                print("ログイン確認処理：成功")
                if (error == nil){
                    print("ログイン認証：成功")
                    self.isLogedIn = true
                    BestScoreManager().syncBestScore()
                }else{
                    print("ログイン認証：失敗")
                }
            }
        }
    }
    
    func dismissGameViewControllers() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Delegate method for GKGameCenterDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController){
        gameCenterViewController.dismiss(animated: true, completion: nil);
    }
    
    
    //MARK: - Delegate method for HBTutorialViewControllerDelegate
    func backButtonTapped() {
        self.ud.set(true, forKey: "tutorialDisplayed")
        self.dismiss(animated: true, completion: nil)
    }
}
