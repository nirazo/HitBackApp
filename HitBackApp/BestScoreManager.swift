//
//  BestScore.swift
//  HitBackApp
//
//  Created by Kenzo on 2015/03/13.
//  Copyright (c) 2015年 Kenzo. All rights reserved.
//

import Foundation
import GameKit

class BestScoreManager {
    
    var userDefault = NSUserDefaults.standardUserDefaults()
    
    func getBestScoreForStage(stage: GAME_STAGE) -> Int {
        var key : String = userDefaultsKeyDict[stage]!
        
        var bestScore = userDefault.objectForKey(key) as! Int?
        if bestScore == nil {
            userDefault.setObject(0, forKey:key)
            bestScore = 0
        }
        return bestScore!
    }
    
    func updateBestScoreForStage(stage: GAME_STAGE, score: Int) {
        let oldBestScore = getBestScoreForStage(stage)
        if oldBestScore < score {
            var key : String = userDefaultsKeyDict[stage]!
            userDefault.setObject(score, forKey:key)
            println("bestScore updated")
            reportScoreToGameCenterForStage(stage, value: score)
        }
    }
    
    private func reportScoreToGameCenterForStage(stage:GAME_STAGE, value:Int){
        var score:GKScore = GKScore()
        var id = leaderBoardIDDict[stage]
        score.value = Int64(value)
        score.leaderboardIdentifier = id
        var scoreArr:[GKScore] = [score]
        GKScore.reportScores(scoreArr, withCompletionHandler:{(error:NSError!) -> Void in
            if( (error != nil)){
                println("reportScore NG \n\(score)")
            }else{
                println("reportScore OK \n\(score)")
            }
        })
    }
    
    func resetBestScore() {
        userDefault.setObject(0, forKey:BESTSCORE_KEY_NORMAL)
    }
    
    func syncBestScore() {
        for stage in GAME_STAGE.allValues {
            reportScoreToGameCenterForStage(stage, value: getBestScoreForStage(stage))
        }
    }
}