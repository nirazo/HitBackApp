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
    
    var userDefault = UserDefaults.standard
    
    func getBestScoreForStage(stage: GAME_STAGE) -> Int {
        let key : String = bestScoreUserDefaultsKeyDict[stage]!
        
        var bestScore = userDefault.object(forKey: key) as! Int?
        if bestScore == nil {
            userDefault.set(0, forKey:key)
            bestScore = 0
        }
        return bestScore!
    }
    
    func updateBestScoreForStage(stage: GAME_STAGE, score: Int) {
        let oldBestScore = getBestScoreForStage(stage: stage)
        if oldBestScore < score {
            let key : String = bestScoreUserDefaultsKeyDict[stage]!
            userDefault.set(score, forKey:key)
            reportScoreToGameCenterForStage(stage: stage, value: score)
        }
    }
    
    private func reportScoreToGameCenterForStage(stage: GAME_STAGE, value: Int){
        let score = GKScore()
        let id = leaderBoardIDDict[stage] ?? ""
        score.value = Int64(value)
        score.leaderboardIdentifier = id
        let scoreArr = [score]
        GKScore.report(scoreArr, withCompletionHandler:{(error:NSError!) -> Void in
            if( (error != nil)){
                print("reportScore NG \n\(score)")
            }else{
                print("reportScore OK \n\(score)")
            }
        } as? (Error?) -> Void)
    }
    
    func resetBestScore() {
        userDefault.set(0, forKey:BESTSCORE_KEY_NORMAL)
    }
    
    func syncBestScore() {
        for stage in GAME_STAGE.allValues {
            reportScoreToGameCenterForStage(stage: stage, value: getBestScoreForStage(stage: stage))
        }
    }
}
