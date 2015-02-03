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

class HBGameOverViewController: UIViewController {
    var score : Int!
    var bannerView: GADBannerView?
    var delegate : HBGameOverViewControllerDelegate?
    var titleLabel : UILabel?
    var scoreLabel : UILabel?
    var bestScoreLabel : UILabel?
    var buttonToRetry : UIButton?
    var buttonToTitle : UIButton?
    
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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(self.score)")
        
        let ud = NSUserDefaults.standardUserDefaults()
        
        titleLabel = UILabel(frame: CGRectMake(0,0,180,50))
        titleLabel!.text = "Game Over..."
        titleLabel!.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) - titleLabel!.frame.size.height*2)
        titleLabel!.font = UIFont(name: "Helvetica", size: 25.0)
        titleLabel!.textColor = UIColor.whiteColor()
        self.view.addSubview(titleLabel!)
        
        scoreLabel = UILabel(frame: CGRectMake(0, 0, 180, 50))
        scoreLabel!.text = "スコア： \(score)"
        scoreLabel!.center = CGPointMake(CGRectGetMidX(self.view.frame), titleLabel!.center.y + titleLabel!.frame.size.height)
        scoreLabel!.font = UIFont(name: "Helvetica", size: 15.0)
        scoreLabel!.textColor = UIColor.whiteColor()
        self.view.addSubview(scoreLabel!)
        
        bestScoreLabel = UILabel(frame: CGRectMake(0, 0, 180, 50))
        let bestScore = ud.integerForKey("bestScore")
        bestScoreLabel!.text = "ハイスコア： \(bestScore)"
        bestScoreLabel!.center = CGPointMake(CGRectGetMidX(self.view.frame), scoreLabel!.center.y + scoreLabel!.frame.size.height)
        bestScoreLabel!.font = UIFont(name: "Helvetica", size: 15.0)
        bestScoreLabel!.textColor = UIColor.whiteColor()
        self.view.addSubview(bestScoreLabel!)
        
        buttonToTitle = UIButton.buttonWithType(.System) as? UIButton
        buttonToTitle!.bounds.size = CGSize(width: 100, height: 40)
        buttonToTitle!.center = CGPointMake(CGRectGetMidX(self.view.frame), bestScoreLabel!.center.y + bestScoreLabel!.frame.size.height)
        buttonToTitle!.setTitle("タイトルへ", forState: UIControlState.Normal)
        buttonToTitle!.addTarget(self, action: "toTitleTapped:", forControlEvents: .TouchUpInside)
        buttonToTitle!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(buttonToTitle!)
        
        buttonToRetry = UIButton.buttonWithType(.System) as? UIButton
        buttonToRetry!.bounds.size = CGSize(width: 100, height: 40)
        buttonToRetry!.center = CGPointMake(CGRectGetMidX(self.view.frame), buttonToTitle!.center.y + buttonToTitle!.frame.size.height)
        buttonToRetry!.setTitle("もう一度", forState: UIControlState.Normal)
        buttonToRetry!.addTarget(self, action: "toRetryTapped:", forControlEvents: .TouchUpInside)
        buttonToRetry!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(buttonToRetry!)

        
        // 広告表示
        self.bannerView = GADBannerView(adSize: GADAdSizeFullWidthPortraitWithHeight(kGADAdSizeBanner.size.height), origin: CGPointMake(0, CGFloat(self.view.frame.height - kGADAdSizeBanner.size.height)))
        self.bannerView?.backgroundColor = UIColor.redColor()
        self.bannerView?.adUnitID = "ca-app-pub-8756306138420194/2858977665" // 広告ユニットID
        //self.bannerView?.rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        self.bannerView?.rootViewController = self
        self.view?.addSubview(self.bannerView!)
        let request = GADRequest() // リクエストのプロパティにいろいろ設定するターゲティングとかいろいろできるよ
        request.testDevices = [GAD_SIMULATOR_ID] // 実機でテストする場合は、デバイスごとのIDをArrayに追加する(デバッグ時にコンソールにIDが表示されるよ)
        self.bannerView?.loadRequest(request)
        
        self.reportScoreToGameCenter(self.score)
        println("gameOver viewDidLoad")
        
    }
    
    
    private func reportScoreToGameCenter(value:Int){
        var score:GKScore = GKScore()
        score.value = Int64(value)
        score.leaderboardIdentifier = "SpaceCat"
        var scoreArr:[GKScore] = [score]
        GKScore.reportScores(scoreArr, withCompletionHandler:{(error:NSError!) -> Void in
            if( (error != nil)){
                println("reportScore NG \n\(score)")
            }else{
                println("reportScore OK \n\(score)")
            }
        })
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
        //self.delegate?.toTitleTapped()
    }
    
    func toRetryTapped(sender : AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
        //self.delegate?.toRetryTapped()
    }
    
}
