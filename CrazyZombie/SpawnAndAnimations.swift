//
//  SpawnAndAnimations.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-06-08.
//  Copyright © 2018 DGames. All rights reserved.
//

import UIKit
import SpriteKit

class SpawnAndAnimations: NSObject {
    static func spawnZombie(x:CGFloat, y:CGFloat) -> SKSpriteNode{
        DataStore.zombie.position = CGPoint(x:x, y:y)
        DataStore.zombie.zPosition = 50
        return DataStore.zombie
    }
    
    static func spawnEnemyPrimary() -> SKSpriteNode{
        let enemy = SKSpriteNode.init(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.setScale(DataStore.moveRight ? 0.8 : -0.8)
        return enemy
    }
    
    static func spawnCat() -> SKSpriteNode{
        let cat = SKSpriteNode(imageNamed: "cat")
        
        cat.name = "cat"
        cat.setScale(0)
        
        cat.zRotation = -π / 16.0
        return cat
    }
    
    static func catAnimation() -> SKAction{
        
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = SKAction.scale(by: 1/1.2, duration: 0.25)
        let fullScale = SKAction.sequence([scaleUp,scaleDown,scaleUp,scaleDown])
        
        let group = SKAction.group([fullWiggle,fullScale])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        
        return SKAction.sequence(actions)
    }
    
    static func zombieHit(object: SKSpriteNode, scene: GameScene){
        switch object.name {
        case "cat":do {
                object.removeAllActions()
                object.setScale(1.0)
                object.zRotation = 0
                object.name = "train"
                let greenAction = SKAction.colorize(with: UIColor.green, colorBlendFactor: 0.8, duration: TimeInterval(1.0))
                object.run(greenAction)
                DataStore.catsInTrain += 1
                if (DataStore.allowSound){
                    scene.run(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false))
                    
                }
            }
        case "enemy":do {
                if DataStore.zombieIsBlinking == false{
                    let blinkTimes = 10.0
                    let duration = 3.0
                    let blinkAction = SKAction.customAction(
                    withDuration: duration) { node, elapsedTime in
                        let slice = duration / blinkTimes
                        let remainder = Double(elapsedTime).truncatingRemainder(
                            dividingBy: slice)
                        node.isHidden = remainder > slice / 2
                        DataStore.zombieIsBlinking = true
                        
                    }
                    let isNoLongerBlinkingAction = SKAction.run {
                        DataStore.zombieIsBlinking = false;
                        DataStore.zombie.isHidden = false;
                    }
                    
                    let zombieBlinkCodeGroup = SKAction.sequence([blinkAction,isNoLongerBlinkingAction])
                    DataStore.zombie.run(zombieBlinkCodeGroup)
                    if(DataStore.allowSound){
                        scene.run(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false))
                        
                    }
                    
                    let changeEnemyColour = SKAction.colorize(with: UIColor.red, colorBlendFactor:0.2, duration: 0.5)
                    object.run(changeEnemyColour)
                    
                    scene.looseCats()
                    DataStore.lives -= 1
                }
            }
        default:
            object.removeFromParent()
        }
    }
    
    static func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSecond : CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: DataStore.velocity.angle)
        let amountToRotate = min(rotateRadiansPerSecond * CGFloat(DataStore.dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    static func boundsCheckZombie(bottomLeft: CGPoint, topRight: CGPoint){
        if DataStore.zombie.position.x <= bottomLeft.x {
            DataStore.zombie.position.x = bottomLeft.x
            DataStore.velocity.x = -DataStore.velocity.x
        }
        if DataStore.zombie.position.x >= topRight.x {
            DataStore.zombie.position.x = topRight.x
            DataStore.velocity.x = -DataStore.velocity.x
        }
        if DataStore.zombie.position.y <= bottomLeft.y {
            DataStore.zombie.position.y = bottomLeft.y
            DataStore.velocity.y = -DataStore.velocity.y
        }
        if DataStore.zombie.position.y >= topRight.y {
            DataStore.zombie.position.y = topRight.y
            DataStore.velocity.y = -DataStore.velocity.y
        }
    }
    
    static func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        // 3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        
        backgroundNode.zPosition = -2
        backgroundNode.name = "background"
        return backgroundNode
    }
    
    static func moveCatTrain(cat: SKSpriteNode, targetPosition: CGPoint){
        let actionDuration = 0.3
        let offset = targetPosition - cat.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * DataStore.zombieMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
        cat.run(moveAction)
    }
    
    static func setPlayButton(){
        DataStore.playButton.setScale(0.8)
        DataStore.playButton.zPosition = 10
        let buttonFirstAction = SKAction.scale(by: 0.5, duration: 0.5)
        let delay = SKAction.wait(forDuration: 0.2)
        let buttonSecondAction = buttonFirstAction.reversed()
        let buttonActionSequence = SKAction.sequence([buttonFirstAction,delay,buttonSecondAction,delay])
        DataStore.playButton.run(SKAction.repeatForever(buttonActionSequence))
    }
    
    static func setSoundButton(){
        DataStore.soundButton.anchorPoint = CGPoint(x: 1, y: 0)
        DataStore.soundButton.zPosition = 10
    }
    
}