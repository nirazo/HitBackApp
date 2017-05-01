//
//  HBTutorialViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/15.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import UIKit
import Foundation

protocol HBTutorialViewControllerDelegate {
    func backButtonTapped()
}

class HBTutorialViewController: UIViewController, UIScrollViewDelegate {
    let frameSize = UIScreen.main.bounds
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    var scrView = UIScrollView()
    var pageControl: UIPageControl!
    var backgroundView : UIImageView = UIImageView(image: UIImage(named: "background.png"))
    let backButtonSpace : CGFloat = 40.0
    var delegate : HBTutorialViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景
        self.backgroundView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.backgroundView)
        self.view.sendSubview(toBack: self.backgroundView)
        
        // 戻るボタン
        let backButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: self.backButtonSpace * 3, height: self.backButtonSpace))
        backButton.setBackgroundImage(UIImage(named: "backButton.png"), for: .normal)
        backButton.center = CGPoint(x: self.view.frame.midX, y: backButton.frame.size.height / 2 + statusBarHeight)
        backButton.addTarget(self, action: #selector(backTapped(sender:)), for:.touchUpInside)
        self.view.addSubview(backButton)
        
        // tutorial用画像
        let img1 = UIImage(named: "tutorial1.png")
        let img2 = UIImage(named: "tutorial2.png")
        let img3 = UIImage(named: "tutorial3.png")
        let img4 = UIImage(named: "tutorial4.png")
        
        //UIImageViewにUIIimageを追加
        let imageView1 = UIImageView(image:img1)
        let imageView2 = UIImageView(image:img2)
        let imageView3 = UIImageView(image:img3)
        let imageView4 = UIImageView(image:img4)
        let imageViewArray = [imageView1, imageView2, imageView3, imageView4]
        
        // pageControl
        pageControl = UIPageControl()
        pageControl.bounds = CGRect(x: 0, y: 0, width: self.frameSize.width, height: 12)
        pageControl.center = CGPoint(x: self.frameSize.width / 2, y: backButton.frame.maxY + pageControl.frame.size.height / 2)
        pageControl.numberOfPages = imageViewArray.count
        pageControl.currentPage = 0
        self.view.addSubview(pageControl)
        
        scrView.delegate = self
        //表示位置 + 1ページ分のサイズ
        let scrViewOriginY = pageControl.frame.maxY
        scrView.frame = CGRect(x: 0, y: scrViewOriginY, width: frameSize.width, height: frameSize.height)
        
        //全体のサイズ
        scrView.contentSize = CGSize(width: frameSize.width * CGFloat(imageViewArray.count), height: frameSize.height)
        
        //左右に並べる
        imageView1.frame = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height - statusBarHeight)
        imageView2.frame = CGRect(x: frameSize.width * 1, y: 0, width: frameSize.width, height: frameSize.height - statusBarHeight)
        imageView3.frame = CGRect(x: frameSize.width * 2, y: 0, width: frameSize.width, height: frameSize.height - statusBarHeight)
        imageView4.frame = CGRect(x: frameSize.width * 3, y: 0, width: frameSize.width, height: frameSize.height - statusBarHeight)
        
        //viewに追加
        self.view.addSubview(scrView)
        for imageView in imageViewArray {
            scrView.addSubview(imageView)
        }
        
        // １ページ単位でスクロールさせる
        scrView.isPagingEnabled = true
        
        //scroll画面の初期位置
        scrView.contentOffset = CGPoint(x: 0, y: 0);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth : CGFloat = self.scrView.frame.size.width
        let fractionalPage : CGFloat = self.scrView.contentOffset.x / pageWidth
        
        let page : Int = lround(Double(fractionalPage))
        self.pageControl.currentPage = page
    }
    
    
    func backTapped(sender: AnyObject) {
        self.delegate?.backButtonTapped()
    }
    
}
