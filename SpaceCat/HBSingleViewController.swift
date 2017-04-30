//
//  HBSingleViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/13.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import UIKit
import SpriteKit

class HBSingleViewController: HBAbstractBannerAdViewController, SceneEscapeProtocol, HBGameOverViewControllerDelegate {
    
    var skView : SKView?
    var stage : GAME_STAGE = GAME_STAGE.NORMAL
    
    init(stage : GAME_STAGE) {
        super.init(nibName: nil, bundle: nil)
        self.stage = stage
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
//        skView!.showsDrawCount = true;
//        skView!.showsNodeCount = true;
//        skView!.showsFPS = true;
//        skView!.ignoresSiblingOrder = true
        goGameScene(stage: self.stage)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.skView?.presentScene(nil)
    }
    
    
    func goGameScene(stage : GAME_STAGE) {
        self.skView?.isPaused = false
        if (self.skView?.scene != nil) {
            self.skView?.scene?.removeAllChildren()
            self.skView?.presentScene(self.skView?.scene)
        } else {
            let gameScene = HBPlaySceneFactory().create(size: self.skView!.bounds.size, stage: stage)
            gameScene.escapeDelegate = self
            gameScene.scaleMode = .aspectFill
            self.skView!.presentScene(gameScene)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ゲーム画面に広告出すようにしたらコメント外す
        //super.showAds(isWithStatusBar: true)
        //var height = self.view.frame.size.height - self.bannerViewFooter!.frame.size.height
        //self.skView = SKView(frame: CGRectMake(0, 0, self.view.frame.size.width, height))
        self.skView = SKView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(self.skView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func toRetryTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - SceneEscapeProtocol method
    func sceneEscape(scene: SKScene, score: Int) {
        let gameOverVC = HBGameOverViewController(score: score, stage: stage)
        self.navigationController?.pushViewController(gameOverVC, animated: true)
    }
    
    //MARK: - HBGameOverViewControllerDelegate method
    func toTitleTapped() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

