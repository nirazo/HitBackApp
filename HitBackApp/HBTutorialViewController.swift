//
//  HBTutorialViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/15.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation

protocol HBTutorialViewControllerDelegate {
    func backButtonTapped()
}

class HBTutorialViewController: UIViewController, UIScrollViewDelegate {
    let frameSize = UIScreen.mainScreen().applicationFrame.size
    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
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
        self.view.sendSubviewToBack(self.backgroundView)
        
        // 戻るボタン
        var backButton : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, self.backButtonSpace * 3, self.backButtonSpace))
        backButton.setBackgroundImage(UIImage(named: "backButton.png"), forState: .Normal)
        backButton.center = CGPointMake(CGRectGetMidX(self.view.frame), backButton.frame.size.height / 2 + statusBarHeight)
        backButton.addTarget(self, action: "backTapped:", forControlEvents:.TouchUpInside)
        self.view.addSubview(backButton)
        
        // tutorial用画像
        let img1 = UIImage(named: "tutorial1.png")
        let img2 = UIImage(named: "tutorial2.png")
        let img3 = UIImage(named: "tutorial3.png")
        let img4 = UIImage(named: "tutorial4.png")
        
        //UIImageViewにUIIimageを追加
        var imageView1 = UIImageView(image:img1)
        let imageView2 = UIImageView(image:img2)
        let imageView3 = UIImageView(image:img3)
        let imageView4 = UIImageView(image:img4)
        var imageViewArray = [imageView1, imageView2, imageView3, imageView4]
        
        // pageControl
        pageControl = UIPageControl()
        pageControl.bounds = CGRectMake(0, 0, self.frameSize.width, 12)
        pageControl.center = CGPoint(x: self.frameSize.width / 2, y: CGRectGetMaxY(backButton.frame) + pageControl.frame.size.height / 2)
        pageControl.numberOfPages = imageViewArray.count
        pageControl.currentPage = 0
        self.view.addSubview(pageControl)
        
        scrView.delegate = self
        //表示位置 + 1ページ分のサイズ
        var scrViewOriginY = CGRectGetMaxY(pageControl.frame)
        scrView.frame = CGRectMake(0, scrViewOriginY, frameSize.width, frameSize.height)
        
        //全体のサイズ
        scrView.contentSize = CGSizeMake(frameSize.width * CGFloat(imageViewArray.count), frameSize.height)
        
        //左右に並べる
        imageView1.frame = CGRectMake(0, 0, frameSize.width, frameSize.height - statusBarHeight)
        imageView2.frame = CGRectMake(frameSize.width * 1, 0, frameSize.width, frameSize.height - statusBarHeight)
        imageView3.frame = CGRectMake(frameSize.width * 2, 0, frameSize.width, frameSize.height - statusBarHeight)
        imageView4.frame = CGRectMake(frameSize.width * 3, 0, frameSize.width, frameSize.height - statusBarHeight)
        
        //viewに追加
        self.view.addSubview(scrView)
        for imageView in imageViewArray {
            scrView.addSubview(imageView)
        }
        
        // １ページ単位でスクロールさせる
        scrView.pagingEnabled = true
        
        //scroll画面の初期位置
        scrView.contentOffset = CGPointMake(0, 0);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth : CGFloat = self.scrView.frame.size.width
        var fractionalPage : CGFloat = self.scrView.contentOffset.x / pageWidth
        
        let page : Int = lround(Double(fractionalPage))
        self.pageControl.currentPage = page
    }
    
    
    func backTapped(sender: AnyObject) {
        self.delegate?.backButtonTapped()
    }
    
}
