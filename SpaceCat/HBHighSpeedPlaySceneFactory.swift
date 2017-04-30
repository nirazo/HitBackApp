//
//  HBHighSpeedPlaySceneFactory.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/28.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import SpriteKit

class HBHighSpeedPlaySceneFactory: HBPlaySceneFactory {
    override func createGameScene(size: CGSize) -> HBPlayScene {
        return HBHighSpeedPlayScene(size: size)
    }
}