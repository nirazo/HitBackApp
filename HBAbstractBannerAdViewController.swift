//
//  HBAbstractBannerAdViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/17.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit

class HBAbstractBannerAdViewController: UIViewController {
    let FOOTER_AD_UNITID = "ca-app-pub-8756306138420194/2265804461"
    
    var bannerViewFooter: GADBannerView?
    var bannerViewHeader: GADBannerView?

    var request = GADRequest()
    
    func showAds(isWithStatusBar flag: Bool) {
        var headerHeight = (flag == true) ? UIApplication.sharedApplication().statusBarFrame.height as CGFloat : 0.0 as CGFloat
        // 広告
        //request = GADRequest() // リクエストのプロパティにいろいろ設定するターゲティングとかいろいろできるよ
        // simulatorと自機をテストデバイスとして登録
        // request.testDevices = [GAD_SIMULATOR_ID, "3a9ba648dc59b79657b6e0643f300787"] // TODO: リリース前に変えろ
        let leftMargin = (self.view.frame.size.width - kGADAdSizeBanner.size.width) / 2.0
        
        bannerViewFooter = GADBannerView(adSize: kGADAdSizeBanner, origin: CGPointMake(leftMargin, CGRectGetMaxY(self.view.frame) - kGADAdSizeBanner.size.height))
        bannerViewFooter?.adUnitID = FOOTER_AD_UNITID // 広告ユニットID
        bannerViewFooter?.rootViewController = self
        self.view.addSubview(bannerViewFooter!)
        bannerViewFooter?.loadRequest(request)
    }
}