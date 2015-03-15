//
//  HBAbstractInterstitialAdViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/17.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation

class HBAbstractInterstitialAdViewController: HBAbstractBannerAdViewController, GADInterstitialDelegate {
    let AD_SHOW_COUNT_INTERVAL = 3
    let INTERSTITIAL_AD_UNITID = "ca-app-pub-8756306138420194/9789071265"
    
    //var interstitial: GADInterstitial? = GADInterstitial()
    
    func resetInterstitial() {
        println("resetInterstitial")
        interstitial = GADInterstitial()
        interstitial?.adUnitID = INTERSTITIAL_AD_UNITID
        interstitial?.delegate = self
        interstitial?.loadRequest(super.request)
    }
    
    func showInterstitial() {
        println("showInterstitial")
        if (interstitial == nil || isInterstitialDisplayed) {
            self.resetInterstitial()
        }
        // AD_SHOW_COUNT_INTERVAL 回に一度しか表示しない
        interstitialCounter++
        if interstitialCounter < AD_SHOW_COUNT_INTERVAL {
            return
        }
        interstitialCounter = 0
        isInterstitialDisplayed = true
        interstitial?.presentFromRootViewController(self)
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        println("dismissInterstitial")
        self.resetInterstitial()
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        println("interstitialWillDismissScreen")
        self.resetInterstitial()
    }
    
    func didFailToReceiveAdWithError(error: GADRequestError) -> GADInterstitial {
        println("didFailToReceiveAdWithError")
        interstitial = nil
        isInterstitialDisplayed = true
        return interstitial!
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        println("interstitialDidReceiveAd")
        interstitial = ad
        isInterstitialDisplayed = false
    }

}