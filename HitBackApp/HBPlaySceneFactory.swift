//
//  HBPlaySceneFactory.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/28.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import SpriteKit

class HBPlaySceneFactory {
    
    func create(size:CGSize, stage: GAME_STAGE) -> HBPlayScene {
        switch stage {
        case GAME_STAGE.NORMAL:
            return HBNormalPlaySceneFactory().createGameScene(size: size)
        case GAME_STAGE.HIGHSPEED:
            return HBHighSpeedPlaySceneFactory().createGameScene(size: size)
        default:
            return HBNormalPlaySceneFactory().createGameScene(size: size)
        }
    }
    
    func createGameScene(size: CGSize) -> HBPlayScene {
        fatalError("must be overridden")
    }
}
