//
//  GameScene.swift
//  Snake
//
//  Created by Guillaume Robin on 16/09/2018.
//  Copyright © 2018 Guillaume Robin. All rights reserved.
//

import SpriteKit
import Foundation

enum Directions {
    case up, down, left, right, none
}

enum GameStates {
    case start, playing, end
}

class GameScene: SKScene {
    
    // Game State
    private var sprites: [[SKSpriteNode]] = []
    private var map: [[Int]] = []
    private var gameState: GameStates = GameStates.start
    
    // UI State
    private var scoreText: SKLabelNode!
    private var chooseDirectionLabel: SKLabelNode!
    
    // Player State
    private var player: [[Int]] = []
    private var currentDirection: Directions = Directions.none
    private var lastTime: Double = 0
    private var food: Bool = false
    private var score: Int = 0
    
    func generateMap() {
        for y in stride(from: 0, to: Map.height, by: 1) {
            map.append([])
            for _ in stride(from: 0, to: Map.width, by: 1) {
                map[y].append(ItemType.FLOOR)
            }
        }
    }
    
    func generateSprites() {
        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        
        let offsetsWidth = (Map.width - 1) * Map.cellOffset
        let offsetsHeight = (Map.height - 1) * Map.cellOffset
        
        let cellWidth = (width - (Map.startX * 2) - offsetsWidth) / Map.width
        let cellHeight = (height - Map.startY - Map.headerMargin - offsetsHeight) / Map.height
        
        for y in stride(from: 0, to: Map.height, by: 1) {
            sprites.append([])
            for x in stride(from: 0, to: Map.width, by: 1) {
                let sprite = SKSpriteNode()
                
                sprite.size = CGSize(width: cellWidth, height: cellHeight)
                
                switch (map[y][x]) {
                case ItemType.FLOOR:
                    sprite.color = UIColor.darkGray
                    break
                case ItemType.WALL:
                    sprite.color = UIColor.blue
                    break
                case ItemType.BODY:
                    sprite.color = UIColor.cyan
                    break
                case ItemType.FOOD:
                    sprite.color = UIColor.red
                    break
                default:
                    break
                }
                
                sprite.position = CGPoint(x: Map.startX + (Map.cellOffset * x) + (cellWidth * x),
                                          y: (Map.startY + (Map.cellOffset * y) + (cellHeight * y)))
                sprite.anchorPoint = CGPoint(x: 0, y: 0)
                
                sprites[y].append(sprite)
                self.addChild(sprite)
            }
        }
    }
    
    func generatePlayer() {
        map[Map.height / 2][Map.width / 2] = ItemType.BODY
        sprites[Map.height / 2][Map.width / 2].color = UIColor.cyan
        player.append([Map.height / 2, Map.width / 2])
    }
    
    func generateFood() {
        while (self.food == false) {
            let randomX: Int = Int(arc4random_uniform(UInt32(Map.width)))
            let randomY: Int = Int(arc4random_uniform(UInt32(Map.height)))
            
            if (map[randomY][randomX] == ItemType.FLOOR) {
                map[randomY][randomX] = ItemType.FOOD
                self.food = true
            }
        }
    }
    
    func startGame() {
        generateMap()
        generateSprites()
        generatePlayer()
        chooseDirectionLabel = self.childNode(withName: "ChooseDirection") as? SKLabelNode
        scoreText = self.childNode(withName: "ScoreText") as? SKLabelNode
    }
    
    @objc func swipedRight(sender:UISwipeGestureRecognizer){
        currentDirection = Directions.right
    }
    @objc func swipedLeft(sender:UISwipeGestureRecognizer){
        currentDirection = Directions.left
    }
    @objc func swipedUp(sender:UISwipeGestureRecognizer){
        currentDirection = Directions.up
    }
    @objc func swipedDown(sender:UISwipeGestureRecognizer){
        currentDirection = Directions.down
    }
    
    func setupGestures(to view: SKView) {
        let swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(swipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:#selector(swipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action:#selector(swipedUp))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action:#selector(swipedDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    override func didMove(to view: SKView) {
        setupGestures(to: view)
        startGame()
    }
    
    func resetLastPlayerTile() {
        map[player[player.count - 1][Player.Y]][player[player.count - 1][Player.X]] = ItemType.FLOOR
    }
    
    func movePlayer() {
        for i in stride(from: player.count - 1, to: 0, by: -1) {
            player[i][Player.X] = player[i-1][Player.X]
            player[i][Player.Y] = player[i-1][Player.Y]
        }
        
        switch (currentDirection) {
        case Directions.down:
            player[0][Player.Y] = player[0][Player.Y] - 1
            break
        case Directions.up:
            player[0][Player.Y] = player[0][Player.Y] + 1
            break
        case Directions.left:
            player[0][Player.X] = player[0][Player.X] - 1
            break
        case Directions.right:
            player[0][Player.X] = player[0][Player.X] + 1
            break
        case Directions.none:
            break
        }
    }
    
    func updatePlayer() {
        map[player[0][Player.Y]][player[0][Player.X]] = ItemType.BODY
    }
    
    func checkEndGame() -> Bool {
        if (player[0][Player.X] < 0 || player[0][Player.X] >= Map.width) {
            gameState = GameStates.end
            return true
        }
        if (player[0][Player.Y] < 0 || player[0][Player.Y] >= Map.height) {
            gameState = GameStates.end
            return true
        }
        if (map[player[0][Player.Y]][player[0][Player.X]] == ItemType.WALL) {
            gameState = GameStates.end
            return true
        }
        if (map[player[0][Player.Y]][player[0][Player.X]] == ItemType.BODY) {
            gameState = GameStates.end
            return true
        }
        return false
    }
    
    func eatFoodAndExtend() {
        if (map[player[0][Player.Y]][player[0][Player.X]] == ItemType.FOOD) {
            if (player.count > 1) {
                let x2 = player[player.count - 1][Player.X]
                let x1 = player[player.count - 2][Player.X]
                let y2 = player[player.count - 1][Player.Y]
                let y1 = player[player.count - 2][Player.Y]
                
                var dirX = x2-x1
                var dirY = y2-y1
                let length = Int(sqrt(powf(Float(dirX), 2) + powf(Float(dirY), 2)))
                
                dirX /= length
                dirY /= length
                
                if (dirX == 1 && x2 + 1 < Map.width && map[y2][x2 + 1] == ItemType.FLOOR) {
                    map[y2][x2 + 1] = ItemType.BODY
                    player.append([y2, x2 + 1])
                } else if (dirX == -1 && x2 - 1 > 0 && map[y2][x2 - 1] == ItemType.FLOOR) {
                    map[y2][x2 - 1] = ItemType.BODY
                    player.append([y2, x2 - 1])
                } else if (dirY == 1 && y2 + 1 < Map.height && map[y2 + 1][x2] == ItemType.FLOOR) {
                    map[y2 + 1][x2] = ItemType.BODY
                    player.append([y2 + 1, x2])
                } else if (dirY == -1 && y2 - 1 > 0 && map[y2 - 1][x2] == ItemType.FLOOR) {
                    map[y2 - 1][x2] = ItemType.BODY
                    player.append([y2 - 1, x2])
                }
            } else {
                let x2 = player[player.count - 1][Player.X]
                let y2 = player[player.count - 1][Player.Y]
                
                switch (currentDirection) {
                case Directions.up:
                    map[y2 - 1][x2] = ItemType.BODY
                    player.append([y2 - 1, x2])
                    break
                case Directions.down:
                    map[y2 + 1][x2] = ItemType.BODY
                    player.append([y2 + 1, x2])
                    break
                case Directions.right:
                    map[y2][x2 - 1] = ItemType.BODY
                    player.append([y2, x2 - 1])
                    break
                case Directions.left:
                    map[y2][x2 + 1] = ItemType.BODY
                    player.append([y2, x2 + 1])
                    break
                default:
                    break
                }
            }
            
            // Trigger food spawning
            self.food = false
            
            // Update score
            self.score += 1
            self.scoreText.text = "Score: " + String(self.score)
        }
    }
    
    func updateMap() {
        for y in stride(from: 0, to: Map.height, by: 1) {
            for x in stride(from: 0, to: Map.width, by: 1) {
                switch (map[y][x]) {
                case ItemType.FLOOR:
                    sprites[y][x].color = UIColor.darkGray
                    break
                case ItemType.WALL:
                    sprites[y][x].color = UIColor.blue
                    break
                case ItemType.BODY:
                    sprites[y][x].color = UIColor.cyan
                    break
                case ItemType.FOOD:
                    sprites[y][x].color = UIColor.red
                    break
                default:
                    break
                }
            }
        }
    }
    
    func updateGame() {
        resetLastPlayerTile()
        movePlayer()
        
        if (checkEndGame()) {
            return
        }
        
        eatFoodAndExtend()
        updatePlayer()
        generateFood()
        updateMap()
    }
    
    func updateStart() {
        if (currentDirection != Directions.none) {
            chooseDirectionLabel.removeFromParent()
            gameState = GameStates.playing
        }
    }
    
    func updatePlay(_ currentTime: TimeInterval) {
        let updateDeltaTime = (1 / (1 + exp(0.1 * Double(self.score)))) + 0.01
        
        if (lastTime > 0) {
            let elapsedTime = currentTime - lastTime
            if (elapsedTime > updateDeltaTime) {
                updateGame()
                lastTime = currentTime
            }
        } else {
            lastTime = currentTime
        }
    }
    
    func updateEnd() {
        if var scene = SKScene(fileNamed: "GameOverScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFit
            
            let gameOverScene = scene as! GameOverScene
            gameOverScene.setScore(self.score)
            
            scene = gameOverScene as SKScene
            
            // Present the scene
            self.view?.presentScene(scene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch (self.gameState) {
        case GameStates.start:
            updateStart()
            break
        case GameStates.playing:
            updatePlay(currentTime)
            break
        case GameStates.end:
            updateEnd()
            break
        }
    }
}
