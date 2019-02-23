//
//  GameOverScene.swift
//  Snake
//
//  Created by Guillaume Robin on 17/09/2018.
//  Copyright © 2018 Guillaume Robin. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    private var scoreText: SKLabelNode!
    private var score: Int = 0
    
    public func setScore(_ score: Int) {
        self.score = score
    }

    override func didMove(to view: SKView) {
        scoreText = self.childNode(withName: "ScoreText") as? SKLabelNode
        
        self.scoreText.text = "Score: " + String(self.score)
        
        if let bestScore = UserDefaults.standard.object(forKey: "BestScore") as? Int {
            if (bestScore < self.score) {
                UserDefaults.standard.set(self.score, forKey: "BestScore")
            }
        } else {
            UserDefaults.standard.set(self.score, forKey: "BestScore")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodes = self.nodes(at: location)
            
            switch nodes.first?.name {
            case "RestartButton":
                
                if let scene = SKScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    self.view?.presentScene(scene)
                }
                break
            case "QuitButton":
                
                if let scene = SKScene(fileNamed: "GameMenu") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    self.view?.presentScene(scene)
                }
                break
            default:
                break
            }
        }
    }
}
