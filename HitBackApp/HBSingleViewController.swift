//
//  HBSingleViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/13.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import UIKit
import SpriteKit

class HBSingleViewController: UIViewController, SceneEscapeProtocol, HBGameOverViewControllerDelegate {
    
    var skView : SKView?
    
    override func loadView() {
        var skView : SKView = SKView(frame: UIScreen.mainScreen().bounds)
        self.view = skView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        goGameScene()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.skView?.presentScene(nil)
    }
    
    
    func goGameScene() {
        self.skView?.paused = false
        if (self.skView?.scene != nil) {
            self.skView?.scene?.removeAllChildren()
            self.skView?.presentScene(self.skView?.scene)
        } else {
            let gameScene = HBSinglePlayScene(size: self.view.bounds.size)
            gameScene.escapeDelegate = self
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.skView!.presentScene(gameScene)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        skView = self.view as? SKView
        skView!.showsDrawCount = true;
        skView!.showsNodeCount = true;
        skView!.showsFPS = true;
        skView!.ignoresSiblingOrder = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func toRetryTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - SceneEscapeProtocol method
    func sceneEscape(scene: SKScene, score: Int) {
        var gameOverVC = HBGameOverViewController(score: score)
        self.navigationController?.pushViewController(gameOverVC, animated: true)
    }
    
    //MARK: - HBGameOverViewControllerDelegate method
    func toTitleTapped() {

        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}

