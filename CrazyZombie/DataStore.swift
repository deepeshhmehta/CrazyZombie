//
//  Values.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-06-08.
//  Copyright © 2018 DGames. All rights reserved.
//

import UIKit
import SpriteKit

class DataStore: NSObject {
    static let zombie: SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    static let textures: [SKTexture] = [
            SKTexture(imageNamed: "zombie1"),
            SKTexture(imageNamed: "zombie2"),
            SKTexture(imageNamed: "zombie3"),
            SKTexture(imageNamed: "zombie4"),]
    
    static let playButton : SKSpriteNode = SKSpriteNode.init(imageNamed: "play_button")
    static var soundButton : SKSpriteNode = SKSpriteNode.init(imageNamed: "sound")
    static let backgroundMainMenu = SKSpriteNode.init(imageNamed: "MainMenu")
    static var secondaryEnemyButton : SKSpriteNode = SKSpriteNode.init(imageNamed: "enemySecondary")
    static var flowerButton : SKSpriteNode = SKSpriteNode.init(imageNamed: "sunflower")
    static var smallFishButton : SKSpriteNode = SKSpriteNode.init(imageNamed: "smallFish")
    static var bigFishButton : SKSpriteNode = SKSpriteNode.init(imageNamed: "bigFish")
    
    static let zombieAnimation = SKAction.animate(with: DataStore.textures, timePerFrame: 0.1)
    static let cameraNode: SKCameraNode = SKCameraNode()
    
    static var lastUpdateTime: TimeInterval = 0
    static var dt: TimeInterval = 0
    static let zombieMovePointsPerSec: CGFloat = 400.0
    static let zombieRadiansPerSecond: CGFloat = 4.0 * CGFloat.pi
    static let cameraMovePointsPerSec: CGFloat = 200.0
    static var velocity: CGPoint = CGPoint(x:0, y:0)
    static var destination: CGPoint = CGPoint(x:0, y:0)
    static var playableRect: CGRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    
    static var lives = 5
    static var catsInTrain = 0
    
    static var zombieIsBlinking = false
    static var gameOver = false
    static var moveRight = false
    static var won = false
    static var allowSound : Bool = true
    static var secondaryEnemyEnabled: Bool = false
    static var flowerEnabled: Bool = false
    static var smallFishEnabled: Bool = false
    static var bigFishEnabled: Bool = false
    static var bigFishMode: Bool = false
    
    static let π = CGFloat.pi
    static let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    static let catsInTrainLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    
    
}
