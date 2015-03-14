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
    
    func getBestScore() -> Int {
        var bestScore = userDefault.objectForKey(BESTSCORE_KEY) as Int?
        if bestScore == nil {
            userDefault.setObject(0, forKey:BESTSCORE_KEY)
            bestScore = 0
        }
        return bestScore!
    }
    
    func updateBestScore(score: Int) {
        let oldBestScore = getBestScore()
        if oldBestScore < score {
            userDefault.setObject(score, forKey:BESTSCORE_KEY)
            println("highScore updated")
            
            reportScoreToGameCenter(score)
        }
    }
    
    private func reportScoreToGameCenter(value:Int){
        var score:GKScore = GKScore()
        score.value = Int64(value)
        score.leaderboardIdentifier = LEADERBOARD_ID
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
        userDefault.setObject(0, forKey:BESTSCORE_KEY)
    }
    
    func syncBestScore() {
        reportScoreToGameCenter(getBestScore())
    }
}