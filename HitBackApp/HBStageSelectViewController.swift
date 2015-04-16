//
//  HBStageSelectViewController.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/29.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit

class HBStageSelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var collectionView:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        view.addSubview(collectionView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : HBStageCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! HBStageCell
        cell.backgroundColor = UIColor.grayColor()
        //cell.imageView!.image = UIImage(named: "quickEnemy.png")!
        cell.setImage(UIImage(named: "quickEnemy.png")!)
        return cell
    }
    
}
