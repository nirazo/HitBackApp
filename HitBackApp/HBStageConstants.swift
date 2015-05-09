//
//  HBStageConstants.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/05/06.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

enum GAME_STAGE : Int {
    case NORMAL = 0
    case HIGHSPEED = 1
    static let allValues = [NORMAL, HIGHSPEED]
}

let stageThumbnailDict : Dictionary<GAME_STAGE, String> = [GAME_STAGE.NORMAL    : "enemy.png",
    GAME_STAGE.HIGHSPEED : "quickEnemy.png"]

let stageNameDict : Dictionary<GAME_STAGE, String> = [GAME_STAGE.NORMAL    : "ふつう",
    GAME_STAGE.HIGHSPEED : "はやい"]

let userDefaultsKeyDict : Dictionary<GAME_STAGE, String> = [GAME_STAGE.NORMAL    : BESTSCORE_KEY_NORMAL,
    GAME_STAGE.HIGHSPEED : BESTSCORE_KEY_HIGHSPEED]

let leaderBoardIDDict : Dictionary<GAME_STAGE, String> = [GAME_STAGE.NORMAL    : LEADERBOARD_ID_NORMAL,
    GAME_STAGE.HIGHSPEED : LEADERBOARD_ID_HIGHSPEED]

