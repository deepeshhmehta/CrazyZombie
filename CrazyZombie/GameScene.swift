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
    private var zombie :SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint(x:0, y: 0)
    var playableRect : CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = ( size.height - playableHeight )/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -2
//        background.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(background)
        
        zombie.position = CGPoint.init(x: 400, y: 400)
        zombie.zPosition = 1
        addChild(zombie)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        move(sprite: zombie,velocity: velocity)
        boundsCheckZombie()
        rotate(sprite: zombie, direction: velocity)
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        // 1
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y  * CGFloat(dt))
        // 2
        sprite.position = CGPoint(
            x: sprite.position.x + amountToMove.x,
            y: sprite.position.y + amountToMove.y)
    }
    
    func moveZombieToward(location: CGPoint) {
        
        let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        moveZombieToward(location: touchLocation)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        moveZombieToward(location: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0 + zombie.size.width / 2, y: playableRect.minY + zombie.size.height / 2)
        let topRight = CGPoint(x: size.width - zombie.size.width / 2, y: playableRect.maxY - zombie.size.height / 2)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = atan2(direction.y, direction.x)
    }
    
    
}
