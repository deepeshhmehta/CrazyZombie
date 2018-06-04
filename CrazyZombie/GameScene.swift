//
//  GameScene.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-05-31.
//  Copyright © 2018 DGames. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -2
//        background.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(background)
        
        let zombie = SKSpriteNode(imageNamed: "zombie1")
        zombie.position = CGPoint.init(x: 400, y: 400)
        zombie.zPosition = 1
        addChild(zombie)
        }
}
