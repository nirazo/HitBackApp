//
//  HBStageCell.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/30.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import UIKit

protocol HBStageCellDelegate {
    func stageCellTapped(cell: HBStageCell)
}

class HBStageCell: UICollectionViewCell {
    var imageView : UIImageView!
    var stage : GAME_STAGE?
    var titleLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true;
        self.imageView = UIImageView(frame: frame)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.imageView!)
        
        _ = frame.size.height / 3
        self.titleLabel = UILabel(frame: CGRect(x: 0, y: frame.size.height*2 / 3, width: frame.size.width, height: frame.size.height / 3))
        self.titleLabel.textColor = .white
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(self.titleLabel)
    }
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetImage() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.frame = contentView.bounds
        self.imageView.clipsToBounds = true
    }
    
    func setImage(image: UIImage) {
        resetImage()
        self.imageView.image = image
    }
    
    func setImageAndTitle() {
        self.setImage(image: UIImage(named: stageThumbnailImageNameDict[self.stage!]!)!)
        self.titleLabel.text = stageNameDict[self.stage!]
    }
    
    func setImageAndTitleForComingSoon() {
        self.setImage(image: UIImage(named: "question")!)
        self.titleLabel.text = "準備中..."
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        resetImage()
    }
}
