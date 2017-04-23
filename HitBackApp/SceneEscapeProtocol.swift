//
//  SceneEscapeProtocol.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/01/27.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import SpriteKit

@objc
protocol SceneEscapeProtocol {
    @objc optional func sceneEscape(scene: SKScene)
    @objc optional func sceneEscape(scene: SKScene, score: Int)
}
