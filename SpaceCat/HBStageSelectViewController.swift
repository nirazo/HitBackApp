//
//  HBStageSelectViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/29.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit

class HBStageSelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, HBTutorialViewControllerDelegate {
    var collectionView:UICollectionView!
    var backgroundView : UIImageView = UIImageView(image: UIImage(named: "background.png"))
    // NSUserDefaults
    let ud = UserDefaults.standard
    
    let NUMOFSTAGES : Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ステージをえらんでね"
        
        // レイアウト作成
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        
        // コレクションビュー作成
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowLayout)
        collectionView.register(HBStageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundView = self.backgroundView
        view.addSubview(collectionView)
        
        // 広告表示
        //super.showAds(isWithStatusBar: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        // タイトルの設定
        let titleImageView : UIImageView = UIImageView(image: UIImage(named: "stageSelectTitle"))
        titleImageView.frame.size = CGSize(width: self.view.frame.size.width/2, height: self.navigationController!.navigationBar.frame.size.height)
        let bgView : UIView = UIView(frame: titleImageView.frame)
        bgView.backgroundColor = .clear
        bgView.addSubview(titleImageView)
        self.navigationItem.titleView = bgView
        
        // 戻るボタンの設定
        let backButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 35))
        backButton.setBackgroundImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
        let buttonItem : UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = buttonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped(sender : AnyObject?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: UICollectionViewDelegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUMOFSTAGES + 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : HBStageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! HBStageCell
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row == NUMOFSTAGES) {
            return;
        }
        if (!ud.bool(forKey: "tutorialDisplayed")) {
            let vc : HBTutorialViewController = HBTutorialViewController()
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        let selectedCell = collectionView.cellForItem(at: indexPath as IndexPath) as! HBStageCell
        let vc : HBSingleViewController = HBSingleViewController(stage: selectedCell.stage!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Delegate method for HBTutorialViewControllerDelegate
    func backButtonTapped() {
        self.ud.set(true, forKey: "tutorialDisplayed")
        self.dismiss(animated: true, completion: nil)
    }
}
