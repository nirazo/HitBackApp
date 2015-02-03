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
        var titleLabel : UILabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 60))
        titleLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) - titleLabel.frame.size.height)
        titleLabel.text = "守れ！！宇宙ねこ"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        self.view.addSubview(titleLabel)
        
        
        var singleStart : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 180, 40))
        singleStart.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMinY(titleLabel.frame) + singleStart.frame.size.height*3)
        singleStart.setTitle("はじめる", forState: .Normal)
        singleStart.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        singleStart.addTarget(self, action: "singleStartTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(singleStart)
        
        
        var scoreButton : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 180, 40))
        scoreButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMinY(singleStart.frame) + scoreButton.frame.size.height*3)
        scoreButton.setTitle("きろく", forState: .Normal)
        scoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        scoreButton.addTarget(self, action: "scoreButtonTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(scoreButton)

        self.loginGameCenter()
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