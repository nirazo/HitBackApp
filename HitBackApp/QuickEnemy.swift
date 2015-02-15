//
//  QuickEnemy.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/07.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import SpriteKit

class QuickEnemy : EnemyBase {
    
    private  struct Config {
        static let MARGIN = 16.0
        static let WIDTH = 50.0
        static let HEIGHT = 18.0
        static let MAX_LIFE = 1
    }
    
    init(level: Int, category: UInt32) {
        super.init(size:CGSize(width: Config.WIDTH,
            height   : Config.HEIGHT),
            life     : Config.MAX_LIFE,
            level    : level,
            fallTime : 15.0,
            image    : UIImage(named: "quickEnemy.png")!,
            category : category)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
