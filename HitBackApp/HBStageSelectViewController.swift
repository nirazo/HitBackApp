//
//  HBStageSelectViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/29.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit

class HBStageSelectViewController: HBAbstractBannerAdViewController, UICollectionViewDataSource, UICollectionViewDelegate, HBTutorialViewControllerDelegate {
    var collectionView:UICollectionView!
    var backgroundView : UIImageView = UIImageView(image: UIImage(named: "background.png"))
    // NSUserDefaults
    let ud = NSUserDefaults.standardUserDefaults()
    
    let NUMOFSTAGES : Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ステージをえらんでね"
        
        // レイアウト作成
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.itemSize = CGSizeMake(100, 100)
        
        // コレクションビュー作成
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowLayout)
        collectionView.registerClass(HBStageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundView = self.backgroundView
        view.addSubview(collectionView)
        
        // 広告表示
        super.showAds(isWithStatusBar: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        
        // タイトルの設定
        var titleImageView : UIImageView = UIImageView(image: UIImage(named: "stageSelectTitle"))
        titleImageView.frame.size = CGSize(width: self.view.frame.size.width/2, height: self.navigationController!.navigationBar.frame.size.height)
        var bgView : UIView = UIView(frame: titleImageView.frame)
        bgView.backgroundColor = UIColor.clearColor()
        bgView.addSubview(titleImageView)
        self.navigationItem.titleView = bgView
        
        // 戻るボタンの設定
        var backButton : UIButton = UIButton(frame: CGRectMake(0, 0, 70, 35))
        backButton.setBackgroundImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
        var buttonItem : UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = buttonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped(sender : AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UICollectionViewDelegate methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUMOFSTAGES + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : HBStageCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! HBStageCell
        
        switch indexPath.row {
        case 0:
            cell.stage = GAME_STAGE.NORMAL
            cell.setImageAndTitle()
            break
        case 1:
            cell.stage = GAME_STAGE.HIGHSPEED
            cell.setImageAndTitle()
        case 2:
            cell.setImageAndTitleForComingSoon()
        default:
            break
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == NUMOFSTAGES) {
            return;
        }
        if (!ud.boolForKey("tutorialDisplayed")) {
            var vc : HBTutorialViewController = HBTutorialViewController()
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! HBStageCell
        var vc : HBSingleViewController = HBSingleViewController(stage: selectedCell.stage!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Delegate method for HBTutorialViewControllerDelegate
    func backButtonTapped() {
        self.ud.setBool(true, forKey: "tutorialDisplayed")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
