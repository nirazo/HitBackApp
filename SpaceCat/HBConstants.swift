//
//  HBConstants.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/02/20.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//
import UIKit

let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone

let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
let IS_RETINA = UIScreen.main.scale >= 2.0

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let SCREEN_MAX_LENGTH: CGFloat = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH: CGFloat = min(SCREEN_WIDTH, SCREEN_HEIGHT)

let IS_IPHONE_4_OR_LESS = IS_IPHONE && (SCREEN_MAX_LENGTH < 568.0)
let IS_IPHONE_5 = IS_IPHONE && (SCREEN_MAX_LENGTH == 568.0)
let IS_IPHONE_6 = IS_IPHONE && (SCREEN_MAX_LENGTH == 667.0)
let IS_IPHONE_6P = IS_IPHONE && (SCREEN_MAX_LENGTH == 736.0)

let BESTSCORE_KEY_NORMAL = "bestScore"
let BESTSCORE_KEY_HIGHSPEED = "bestScore_highSpeed"
let LEADERBOARD_ID_NORMAL = "spaceCatNormal"
let LEADERBOARD_ID_HIGHSPEED = "spaceCatHighSpeed"

let titleFooterAdID = "ca-app-pub-8501671653071605/1974659335"
let gameOverFooterAdID = "ca-app-pub-1155557522194155/2642519225"


let DEBUG = false
