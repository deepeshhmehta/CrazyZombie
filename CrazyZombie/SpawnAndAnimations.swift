//
//  SpawnAndAnimations.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-06-08.
//  Copyright © 2018 DGames. All rights reserved.
//

import UIKit
import SpriteKit
// class defined to write spawn and animations logic. also a few helper functions are written here to take load off the GameScene
class SpawnAndAnimations: NSObject {
    
    //animation required to wiggle and zoom in & out
    static var wiggleAndZoomInOutAnimation: SKAction{
        let optionButtonRotateLeft = SKAction.rotate(byAngle: 2, duration: 0.5)
        let optionButtonSizeUp = SKAction.scale(by: 1.2, duration: 0.25)
        let shake = SKAction.sequence([optionButtonRotateLeft,optionButtonRotateLeft.reversed()])
        let shiver = SKAction.sequence([optionButtonSizeUp,optionButtonSizeUp.reversed(),optionButtonSizeUp,optionButtonSizeUp.reversed()])
        let action = SKAction.group([shake,shiver])
        return action
    }
    
    //animation sequence required for flower movement
    static var flowerAnimation: SKAction{
        let threeSeconds = SKAction.repeat(SpawnAndAnimations.wiggleAndZoomInOutAnimation, count: 3)
        let max = DataStore.playableRect.maxY - DataStore.flowerButton.size.height
        let min = DataStore.playableRect.minY + DataStore.flowerButton.size.height
        let moveToScreen = SKAction.moveTo(y: CGFloat.random(min: min , max: max) , duration: 1.0)
        let actionDisapear = SKAction.scale(to: 0.0, duration: 0.5)
        let removeAction = SKAction.removeFromParent()
        let flowerAnimation = SKAction.sequence([
            moveToScreen,
            threeSeconds,
            actionDisapear,
            removeAction
            ])
        return flowerAnimation
    }
    
    //animation required for fish
    static var fishAnimation: SKAction {
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let fourSeconds = SKAction.repeat(SpawnAndAnimations.wiggleAndZoomInOutAnimation, count: 4)
        let actionDisapear = SKAction.scale(to: 0.0, duration: 0.5)
        let removeAction = SKAction.removeFromParent()
        let fishAnimation = SKAction.sequence([
            appear,
            fourSeconds,
            actionDisapear,
            removeAction
            ])
        return fishAnimation
    }
    
    //returns animation sequence required for cats
    static var catAnimation: SKAction{
        
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
    
    //set location and return zombie to be added to game
    static func spawnZombie(x:CGFloat, y:CGFloat) -> SKSpriteNode{
        DataStore.zombie.position = CGPoint(x:x, y:y)
        DataStore.zombie.zPosition = 50
        return DataStore.zombie
    }
    
    //sets camera location independednt parameters, sets constants depending on enemy being primary or secondary and returns enemy object
    static func spawnEnemy(type: String) -> SKSpriteNode{
        let enemy = SKSpriteNode.init(imageNamed: "enemy")
        enemy.name = "enemy"
        let multiplcationFactor: CGFloat = (type == "primary") ? 1.0 : (type == "secondary") ? -1.0 : 0.0
        enemy.setScale(DataStore.moveRight ? 0.8 * multiplcationFactor : -0.8 * multiplcationFactor)
        return enemy
    }
    
    //sets camera location independent parameters, returns cat object
    static func spawnCat() -> SKSpriteNode{
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.setScale(0)
        cat.zRotation = -π / 16.0
        return cat
    }
    
    //sets camera location independent parameters, returns flower object for the game
    static func spawnFlower() -> SKSpriteNode{
        let flower = SKSpriteNode.init(imageNamed: "sunflower")
        flower.name = "flower"
        flower.size = CGSize(width: 190.0, height: 190.0)
        flower.position.y = DataStore.playableRect.maxY + flower.size.height/2
        flower.run(SpawnAndAnimations.flowerAnimation)
        return flower
    }
    //sets camera location independent parameters, returns fish object for the game depending on type passed ("small" / "big")
    static func spawnFish(type: String) -> SKSpriteNode{
        let fish = SKSpriteNode.init(imageNamed: type + "Fish")
        fish.name = type + "Fish"
        fish.setScale(0.0)
        fish.size = CGSize(width: 190.0, height: 190.0)
        fish.position.y = CGFloat.random(min: DataStore.playableRect.minY + fish.size.height, max: DataStore.playableRect.maxY - fish.size.height)
        fish.run(SpawnAndAnimations.fishAnimation)
        return fish
    }
    
    
    //check what object hit zombie and take necessary action
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
            
        case "flower":do {
                DataStore.lives += 1
                object.removeFromParent()
                if(DataStore.allowSound){
                    scene.run(SKAction.playSoundFileNamed("flowerTouched.wav", waitForCompletion: false))
                    
                }
            }
        case "smallFish":do {
            DataStore.zombieIsBlinking = true
            object.removeFromParent()
            let changeColor = SKAction.colorize(with: UIColor.orange, colorBlendFactor: 1.0, duration: 0.5)
            let changeColorCat = SKAction.run {
                scene.enumerateChildNodes(withName: "train") { node, stop in
                    node.run(changeColor)
                }
            }
            let changeColorBack = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
            let changeColorBackCatColour = SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.5)
            let changeColorBackCat = SKAction.run {
                scene.enumerateChildNodes(withName: "train") { node, stop in
                    node.run(changeColorBackCatColour)
                }
            }
            let delay = SKAction.wait(forDuration: 4.0)
            let logic = SKAction.run {
                DataStore.zombieIsBlinking = false
            }
            let actionSequence = SKAction.sequence([
                changeColor, changeColorCat,
                delay,
                changeColorBack, changeColorBackCat,
                logic
                ])
            DataStore.zombie.run(actionSequence)
            
            if(DataStore.allowSound){
                scene.run(SKAction.playSoundFileNamed("flowerTouched.wav", waitForCompletion: false))
                
            }
        }
        case "bigFish":do {
            DataStore.bigFishMode = true
            object.removeFromParent()
            let changeColor = SKAction.colorize(with: UIColor.blue, colorBlendFactor: 1.0, duration: 0.5)
            let changeColorBack = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
                        let delay = SKAction.wait(forDuration: 4.0)
            let logic = SKAction.run {
                DataStore.bigFishMode = false
            }
            let actionSequence = SKAction.sequence([
                changeColor,
                delay,
                changeColorBack,
                logic
                ])
            DataStore.zombie.run(actionSequence)
            if(DataStore.allowSound){
                scene.run(SKAction.playSoundFileNamed("flowerTouched.wav", waitForCompletion: false))
                
            }
        }
        default:
            object.removeFromParent()
        }
        SpawnAndAnimations.updateLabels()
    }
    
    //rotate helper function
    static func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSecond : CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: DataStore.velocity.angle)
        let amountToRotate = min(rotateRadiansPerSecond * CGFloat(DataStore.dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    //check if zombie is going out of screen
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
    
    //function used to create a background node
    static func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        
        backgroundNode.zPosition = -3
        backgroundNode.name = "background"
        return backgroundNode
    }
    
    //function to move cats in a train
    static func moveCatTrain(cat: SKSpriteNode, targetPosition: CGPoint){
        let actionDuration = 0.3
        let offset = targetPosition - cat.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * DataStore.zombieMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
        cat.run(moveAction)
    }
    
    //set constant values of playbutton
    static func setPlayButton(){
        DataStore.playButton.setScale(0.8)
        DataStore.playButton.zPosition = 10
        let buttonFirstAction = SKAction.scale(by: 0.5, duration: 0.5)
        let delay = SKAction.wait(forDuration: 0.2)
        let buttonSecondAction = buttonFirstAction.reversed()
        let buttonActionSequence = SKAction.sequence([buttonFirstAction,delay,buttonSecondAction,delay])
        DataStore.playButton.run(SKAction.repeatForever(buttonActionSequence))
    }
    
    //set constant values of sound button
    static func setSoundButton(){
        DataStore.soundButton.anchorPoint = CGPoint(x: 1, y: 0)
        DataStore.soundButton.zPosition = 10
    }
    
    //set constant values of add on option buttons
    static func setOptionButton(button: inout SKSpriteNode){
        button.zRotation = -1
        button.size = CGSize(width: 180.0, height: 180.0)
        button.position.x = DataStore.playableRect.minX + button.size.width
        button.run(SKAction.repeatForever(SpawnAndAnimations.wiggleAndZoomInOutAnimation))
    }
    
    //set constants of labels
    static func setLabels(){
        DataStore.livesLabel.fontColor = SKColor.black
        DataStore.livesLabel.fontSize = 100
        DataStore.livesLabel.zPosition = 150
        DataStore.livesLabel.horizontalAlignmentMode = .left
        DataStore.livesLabel.verticalAlignmentMode = .bottom
        DataStore.livesLabel.position = CGPoint(
            x: -DataStore.playableRect.size.width/2 + CGFloat(20),
            y: -DataStore.playableRect.size.height/2 + CGFloat(20))
        
        DataStore.catsInTrainLabel.fontColor = SKColor.black
        DataStore.catsInTrainLabel.fontSize = 100
        DataStore.catsInTrainLabel.zPosition = 150
        DataStore.catsInTrainLabel.horizontalAlignmentMode = .right
        DataStore.catsInTrainLabel.verticalAlignmentMode = .bottom
        DataStore.catsInTrainLabel.position = CGPoint(
            x: DataStore.playableRect.size.width/2 - CGFloat(20),
            y: -DataStore.playableRect.size.height/2 + CGFloat(20))
        
        SpawnAndAnimations.updateLabels()
    }
    
    //fetch new data to be shown in labels
    static func updateLabels(){
        DataStore.livesLabel.text = "Lives: " + String(DataStore.lives)
        DataStore.catsInTrainLabel.text = "Cats: " + String(DataStore.catsInTrain)
    }
    
    //check option button clicked
    
    static func checkOptionButtonClicked(touch: UITouch, scene: MainMenuScene){
        if(DataStore.soundButton.contains(touch.location(in: scene))){
            if DataStore.allowSound{
                DataStore.allowSound = false
                DataStore.soundButton.texture = SKTexture(imageNamed: "noSound")
            }else{
                DataStore.allowSound = true
                DataStore.soundButton.texture = SKTexture(imageNamed: "sound")
            }
        }
        
        if(DataStore.secondaryEnemyButton.contains(touch.location(in: scene))){
            DataStore.secondaryEnemyEnabled = !DataStore.secondaryEnemyEnabled
            
            let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.secondaryEnemyEnabled ? 1.0 : 0.0, duration: 0.0)
            DataStore.secondaryEnemyButton.run(colourAction)
        }
        
        if(DataStore.flowerButton.contains(touch.location(in: scene))){
            DataStore.flowerEnabled = !DataStore.flowerEnabled
            
            let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.flowerEnabled ? 1.0 : 0.0, duration: 0.0)
            DataStore.flowerButton.run(colourAction)
        }
        
        if(DataStore.smallFishButton.contains(touch.location(in: scene))){
            DataStore.smallFishEnabled = !DataStore.smallFishEnabled
            
            let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.smallFishEnabled ? 1.0 : 0.0, duration: 0.0)
            DataStore.smallFishButton.run(colourAction)
        }
        
        if(DataStore.bigFishButton.contains(touch.location(in: scene))){
            DataStore.bigFishEnabled = !DataStore.bigFishEnabled
            
            let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.bigFishEnabled ? 1.0 : 0.0, duration: 0.0)
            DataStore.bigFishButton.run(colourAction)
        }
    }
    
}
