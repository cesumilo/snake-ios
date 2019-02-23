//
//  GameMenu.swift
//  Snake
//
//  Created by Guillaume Robin on 09/09/2018.
//  Copyright © 2018 Guillaume Robin. All rights reserved.
//

import SpriteKit

class GameMenu: SKScene {

    private var playButton: SKSpriteNode!
    private var scoreText: SKLabelNode!
    
    override func didMove(to view: SKView) {
        self.scaleMode = .aspectFit
        
        playButton = self.childNode(withName: "PlayButton") as? SKSpriteNode
        scoreText = self.childNode(withName: "ScoreText") as? SKLabelNode
        
        if let score = UserDefaults.standard.object(forKey: "BestScore") as? Int {
            scoreText.text = String(score)
        } else {
            scoreText.text = ""
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodes = self.nodes(at: location)
            
            switch nodes.first?.name {
            case "PlayButton":
                print("Start game!")
                
                if let scene = SKScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    
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
