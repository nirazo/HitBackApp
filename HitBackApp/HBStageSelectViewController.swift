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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : HBStageCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! HBStageCell
        
        switch indexPath.row {
        case 0:
            cell.stage = GAME_STAGE.NORMAL
            break
        case 1:
            cell.stage = GAME_STAGE.HIGHSPEED
        default:
            break
        }
        cell.setImageAndTitle()
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
