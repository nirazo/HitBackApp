//
//  HBTitleViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/12.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit
import GoogleMobileAds
import SnapKit

class HBTitleViewController: UIViewController, HBTutorialViewControllerDelegate, GADBannerViewDelegate {
    var catView = UIImageView(image: UIImage(named: "spaceCat.png"))
    
    var titleView = UIImageView(image: UIImage(named: "titleImage.png"))
    var backgroundView = UIImageView(image: UIImage(named: "background.png"))
    var earthView = UIImageView(image: UIImage(named: "earth.png"))
    
    let TITLE_MARGIN_Y_IPHONE5ORMORE : CGFloat = 60.0
    let PARTS_MARGIN_Y_IPHONE5ORMORE : CGFloat = 20.0
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = titleFooterAdID
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
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
        
        let titleMarginY : CGFloat = TITLE_MARGIN_Y_IPHONE5ORMORE
        let partsMarginY : CGFloat = PARTS_MARGIN_Y_IPHONE5ORMORE
        
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
        self.catView.frame.size = CGSize(width: 144, height: 123.36)
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
        let singleStart : UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 144, height: 48))
        singleStart.setBackgroundImage(UIImage(named: "startButton.png"), for: .normal)
        singleStart.center = CGPoint(x: self.view.frame.midX, y: self.catView.frame.maxY + singleStart.frame.size.height/2 + partsMarginY)
        singleStart.addTarget(self, action: #selector(singleStartTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(singleStart)
        
        // チュートリアル表示ボタン
        let tutorialButton : UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 144, height: 48))
        tutorialButton.setBackgroundImage(UIImage(named: "tutorialButton.png"), for: .normal)
        tutorialButton.center = CGPoint(x: self.view.frame.midX, y: singleStart.frame.maxY + tutorialButton.frame.size.height/2 + partsMarginY)
        tutorialButton.addTarget(self, action: #selector(tutorialButtonTapped(sender: )), for:.touchUpInside)
        self.view.addSubview(tutorialButton)
        

        // 広告表示
        let req = GADRequest()
        #if DEBUG
            req.testDevices = [kGADSimulatorID]
            print("debug!!!")
        #endif
        view.addSubview(adBannerView)
        adBannerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        adBannerView.load(req)
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
    
    //MARK: - Delegate method for HBTutorialViewControllerDelegate
    func backButtonTapped() {
        self.ud.set(true, forKey: "tutorialDisplayed")
        self.dismiss(animated: true, completion: nil)
    }
}
