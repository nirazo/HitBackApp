//
//  HBNormalPlaySceneFactory.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/28.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import SpriteKit

class HBNormalPlaySceneFactory: HBPlaySceneFactory {
    override func createGameScene(size: CGSize) -> HBPlayScene {
        return HBSinglePlayScene(size: size)
    }
}
