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
    func stageCellTapped()
}

class HBStageCell: UICollectionViewCell {
    var imageView : UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true;
        self.imageView = UIImageView(frame: frame)
        self.imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.imageView.contentMode = .ScaleAspectFit
        self.contentView.addSubview(self.imageView!)
        let viewsDictionary = ["imageView" : imageView]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]", options: .allZeros, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView]", options: .allZeros, metrics: nil, views: viewsDictionary))

        //self.setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetImage() {
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.frame = contentView.bounds
        self.imageView.clipsToBounds = true
    }
    
    func setImage(image: UIImage) {
        resetImage()
        self.imageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        resetImage()
    }
}
